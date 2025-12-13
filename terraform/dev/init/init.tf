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
resource "aws_iam_user" "supanova_infra_dev_user" {
  name = "supanova-infra-dev"
  tags = {
    Purpose = "Supanova Dev Provisioning"
  }
}

resource "aws_iam_policy" "supanova_infra_dev_policy" {
  name        = "supanova_infra_dev_policy"
  description = "Policy for managing Supanova Dev Infra"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ManageAssetsBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketPolicyStatus",
          "s3:GetBucketPolicy",
          "s3:PutBucketPolicy",
          "s3:DeleteBucketPolicy",
          "s3:GetBucketAcl",
          "s3:PutBucketTagging",
          "s3:GetBucketTagging",
          "s3:DeleteBucketTagging",
          "s3:PutBucketPublicAccessBlock",
          "s3:GetBucketPublicAccessBlock",
          "s3:DeleteBucketPublicAccessBlock",
          "s3:GetBucketCORS",
          "s3:GetBucketWebsite",
          "s3:GetBucketVersioning",
          "s3:GetBucketRequestPayment",
          "s3:GetAccelerateConfiguration",
          "s3:GetBucketLogging",
          "s3:GetBucketEncryption",
          "s3:GetBucketLifecycle",
          "s3:GetBucketOwnershipControls",
          "s3:GetLifecycleConfiguration",
          "s3:GetReplicationConfiguration",
          "s3:GetEncryptionConfiguration",
          "s3:GetBucketObjectLockConfiguration"
        ]
        Resource = "arn:aws:s3:::supanova-dev"
      },
      {
        Sid    = "ManageBackupBucket"
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = "arn:aws:s3:::supanova-db-backup-dev"
      },
      {
        Sid    = "IAMUserManagement"
        Effect = "Allow"
        Action = [
          "iam:CreateUser",
          "iam:DeleteUser",
          "iam:GetUser",
          "iam:ListUserTags",
          "iam:TagUser",
          "iam:UntagUser"
        ]
        Resource = [
          "arn:aws:iam::*:user/supanova-maintenance-dev",
          "arn:aws:iam::*:user/supanova-server-dev"
        ]
      },
      {
        Sid    = "IAMPolicyManagement"
        Effect = "Allow"
        Action = [
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicyVersions",
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:SetDefaultPolicyVersion",
          "iam:ListEntitiesForPolicy"
        ]
        Resource = [
          "arn:aws:iam::*:policy/supanova_maintenance_dev_policy",
          "arn:aws:iam::*:policy/supanova_server_dev_policy"
        ]
      },
      {
        Sid    = "IAMPolicyAttachment"
        Effect = "Allow"
        Action = [
          "iam:AttachUserPolicy",
          "iam:DetachUserPolicy",
          "iam:ListAttachedUserPolicies"
        ]
        Resource = [
          "arn:aws:iam::*:user/supanova-maintenance-dev",
          "arn:aws:iam::*:user/supanova-server-dev"
        ]
      },
      {
        Sid    = "IAMAccessKeyManagement"
        Effect = "Allow"
        Action = [
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey",
          "iam:GetAccessKeyLastUsed",
          "iam:ListAccessKeys",
          "iam:UpdateAccessKey"
        ]
        Resource = [
          "arn:aws:iam::*:user/supanova-maintenance-dev",
          "arn:aws:iam::*:user/supanova-server-dev"
        ]
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
      },
      {
        Sid    = "SecretsManagerFullAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:CreateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecret",
          "secretsmanager:TagResource",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:UntagResource"
        ]
        Resource = [
          "arn:aws:secretsmanager:*:*:secret:supanova-dev-*"
        ]
      },
      {
        Sid    = "SecretsManagerList"
        Effect = "Allow"
        Action = [
          "secretsmanager:ListSecrets"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach policy to the user
resource "aws_iam_user_policy_attachment" "infra_user_attach" {
  user       = aws_iam_user.supanova_infra_dev_user.name
  policy_arn = aws_iam_policy.supanova_infra_dev_policy.arn
}

# Create an access key for the user
resource "aws_iam_access_key" "supanova_infra_dev_user_key" {
  user = aws_iam_user.supanova_infra_dev_user.name
}
