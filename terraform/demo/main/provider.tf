terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "supanova-tfstate"
    key          = "demo/main/terraform.tfstate"
    region       = "eu-west-2"
    profile      = "terraform"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region  = "eu-west-2"
  profile = "supanova-infra-demo"
}
