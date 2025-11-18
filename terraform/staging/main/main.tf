terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.6.0"
}

provider "aws" {
  region  = "eu-west-2"
  profile = "supanova-infra-staging"
}

# Upload local SSH public key to AWS
resource "aws_key_pair" "supanova_infra_key" {
  key_name   = "supanova_infra_key"
  public_key = file("~/.ssh/supanova_staging_deploy.pub")
}

# Security group that allows SSH + HTTP
resource "aws_security_group" "supanova_infra_sg" {
  name        = "supanova-infra-sg"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Get AMI for Ubuntu 22.04 LTS
data "aws_ssm_parameter" "ubuntu_22_04" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

locals {
  staging_env_content     = file(var.staging_env_file)
  firebase_config_content = file(var.firebase_config_file)
  users_sql_content       = file(var.users_sql_file)
  nginx_conf_content       = file(var.nginx_conf_file)
}

# EC2 instance - Supanova Staging
resource "aws_instance" "supanova_staging_ec2" {
  ami                    = data.aws_ssm_parameter.ubuntu_22_04.value
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.supanova_infra_key.key_name
  vpc_security_group_ids = [aws_security_group.supanova_infra_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              exec > /var/log/user-data.log 2>&1 # For debugging this script
              set -e

              #########################
              # Setup SSH key for GitLab
              #########################
              mkdir -p /home/ubuntu/.ssh
              chmod 700 /home/ubuntu/.ssh
              cat << 'KEY' > /home/ubuntu/.ssh/id_ed25519
              ${file("~/.ssh/supanova_staging_deploy")}
              KEY
              chmod 600 /home/ubuntu/.ssh/id_ed25519
              chown -R ubuntu:ubuntu /home/ubuntu/.ssh
              ssh-keyscan gitlab.com >> /home/ubuntu/.ssh/known_hosts
              chmod 644 /home/ubuntu/.ssh/known_hosts
              chown ubuntu:ubuntu /home/ubuntu/.ssh/known_hosts

              #########################
              # Update system and install dependencies
              #########################
              apt update -y
              apt install -y nginx git curl gnupg lsb-release postgresql-client make -y

              # Install Node.js + npm
              curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
              sudo apt install -y nodejs

              # Install Docker
              curl -fsSL https://get.docker.com -o get-docker.sh
              sh get-docker.sh
              usermod -aG docker ubuntu

              # Install Docker Compose
              curl -L "https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose

              # Enable and start nginx
              systemctl enable nginx
              systemctl start nginx

              #########################
              # Clone repo
              #########################
              REPO_DIR="/home/ubuntu/supanova-server"
              sudo -u ubuntu git clone git@gitlab.com:jamiegarner123/supanova-server.git "$REPO_DIR"
              chown -R ubuntu:ubuntu "$REPO_DIR"

              #########################
              # Inject environment variables
              #########################
              cat << 'ENV_FILE' > "$REPO_DIR/.env"
              ${replace(local.staging_env_content, "$", "\\$")}
              AWS_ACCESS_KEY_ID=${aws_iam_access_key.supanova_staging_s3_user_key.id}
              AWS_SECRET_ACCESS_KEY=${aws_iam_access_key.supanova_staging_s3_user_key.secret}
              AWS_BUCKET_NAME=${aws_s3_bucket.supanova-staging.bucket}
              ENV_FILE

              chown ubuntu:ubuntu "$REPO_DIR/.env"
              chmod 600 "$REPO_DIR/.env"

              #########################
              # Setup nginx
              #########################
              sudo mkdir -p /etc/ssl/certs /etc/ssl/private

              EC2_PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

              sudo openssl req -x509 -nodes -days 365 \
                -newkey rsa:2048 \
                -keyout /etc/ssl/private/selfsigned.key \
                -out /etc/ssl/certs/selfsigned.crt \
                -subj "/CN=$EC2_PUBLIC_IP"

              sudo rm /etc/nginx/sites-enabled/default

              cat << 'NGINX_CONF' > /etc/nginx/sites-available/supanova
              ${local.nginx_conf_content}
              NGINX_CONF

              sudo ln -s /etc/nginx/sites-available/supanova /etc/nginx/sites-enabled/
              sudo nginx -t
              sudo systemctl restart nginx

              #########################
              # Setup app
              #########################
              sudo npm install -g pm2

              cat <<EOT > "$REPO_DIR/firebase/supanova-firebase-config.json"
              ${local.firebase_config_content}
              EOT

              cat <<EOT > "$REPO_DIR/database/sql/users.sql"
              ${local.users_sql_content}
              EOT

              cd $REPO_DIR
              make install
              make init-db
              sudo -u ubuntu -H bash <<'PM2_SCRIPT'
              make start-pm2
              PM2_SCRIPT
              EOF

  tags = {
    Name = "supanova-staging"
  }
}

output "supanova_staging_ip" {
  value = aws_instance.supanova_staging_ec2.public_ip
}
