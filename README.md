# Supanova Infra

Infrastructure for Supanova Radiation Protection Services learning platform, including:
- Running services in docker
- Provisioning with terraform

## Running services

Run:
```
make up
```

Stop:
```
make down
```

## Terraform

Currently the cloudfront setup is managed by terraform (see terraform/prod).
The S3 bucket and S3 user are currently not managed by terraform but could be in future.

#### Prerequisites:
- AWS CLI
- terraform
- An aws user setup with IAM privileges

#### To setup:
```
cd terraform/prod|dev/init
aws configure --profile <your_aws_user>
terraform init
```

Then:
```
bash init.sh
```
This creates supanova_infra user (if it doesn't already exist) and sets the user's credentials in your local aws config.

#### To apply changes:
```
cd terraform/prod|dev/main
terraform apply
```


### EC2 Staging env setup

A staging version of supanova-server can be setup using EC2 with terraform

#### Prerequisites:
- An ssh key in ~/.ssh/supanova_staging_deploy added as a deploy key in the git repo

#### Creating supanova-infra user:
```
cd terraform/staging/init
terraform init
bash init.sh
```

#### Creating the infra:

```
cd terraform/staging/main
terraform apply
```

#### SSH into server:

Copy the public IP output from the previous step
```
ssh -i ~/.ssh/supanova_staging_deploy ubuntu@<public_ip>
```
