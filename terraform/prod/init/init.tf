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
  profile = "jamie"
}

# Create the IAM user
resource "aws_iam_user" "supanova_infra_prod_user" {
  name = "supanova-infra-prod"
  tags = {
    Purpose = "Supanova Prod Provisioning"
  }
}

resource "aws_iam_policy" "supanova_infra_prod_policy" {
  name        = "supanova_infra_prod_policy"
  description = "Policy for managing Production Supanova Infra"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ManageBucket"
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:GetBucketPolicy",
          "s3:GetBucketPolicyStatus",
          "s3:ListBucket",
          "s3:PutBucketPolicy",
          "s3:DeleteBucketPolicy"
        ]
        Resource = "arn:aws:s3:::supanova-prod"
      },

      {
        Sid    = "CloudFront"
        Effect = "Allow"
        Action = [
          "cloudfront:CreateDistribution",
          "cloudfront:GetDistribution",
          "cloudfront:GetDistributionConfig",
          "cloudfront:UpdateDistribution",
          "cloudfront:DeleteDistribution",
          "cloudfront:TagResource",
          "cloudfront:UntagResource",
          "cloudfront:ListTagsForResource",
          "cloudfront:CreateOriginAccessControl",
          "cloudfront:GetOriginAccessControl",
          "cloudfront:GetOriginAccessControlConfig",
          "cloudfront:UpdateOriginAccessControl",
          "cloudfront:DeleteOriginAccessControl",
          "cloudfront:ListOriginAccessControls",
          "cloudfront:CreateKeyGroup",
          "cloudfront:GetKeyGroup",
          "cloudfront:UpdateKeyGroup",
          "cloudfront:DeleteKeyGroup",
          "cloudfront:CreatePublicKey",
          "cloudfront:GetPublicKey",
          "cloudfront:UpdatePublicKey",
          "cloudfront:DeletePublicKey"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach policy to the user
resource "aws_iam_user_policy_attachment" "infra_user_attach" {
  user       = aws_iam_user.supanova_infra_prod_user.name
  policy_arn = aws_iam_policy.supanova_infra_prod_policy.arn
}

# Create an access key for the user
resource "aws_iam_access_key" "supanova_infra_prod_user_key" {
  user = aws_iam_user.supanova_infra_prod_user.name
}
