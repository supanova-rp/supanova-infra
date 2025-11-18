#!/bin/bash

terraform apply

PROFILE="supanova-infra-prod"

ACCESS_KEY_ID=$(terraform output -raw supanova_infra_access_key_id)
SECRET_ACCESS_KEY=$(terraform output -raw supanova_infra_secret_access_key)
REGION="eu-west-2"

aws configure set aws_access_key_id $ACCESS_KEY_ID --profile $PROFILE
aws configure set aws_secret_access_key $SECRET_ACCESS_KEY --profile $PROFILE
aws configure set region $REGION --profile $PROFILE

echo "AWS profile '$PROFILE' configured successfully!"
