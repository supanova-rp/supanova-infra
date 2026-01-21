# Supanova Infra

Infrastructure for Supanova Radiation Protection Services learning platform, including:
- Running services in docker
- Provisioning with terraform

## Running services

Run on demo environment:
```
make up-demo
```

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
