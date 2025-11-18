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
resource "aws_iam_user" "supanova_infra_staging_user" {
  name = "supanova-infra-staging"
  tags = {
    Purpose = "Supanova Staging Provisioning"
  }
}

resource "aws_iam_policy" "supanova_infra_staging_policy" {
  name        = "supanova_infra_staging_policy"
  description = "Policy for managing Supanova Infra"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2Lifecycle",
        Effect = "Allow",
        Action = [
          "ec2:RunInstances",
          "ec2:StartInstances",
          "ec2:CreateTags",
          "ec2:ModifyInstanceAttribute",
          "ec2:StopInstances",
          "ec2:TerminateInstances",
          "ec2:RebootInstances"
        ],
        Resource = "*"
      },
      {
        Sid    = "EC2Describe"
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeTags",
          "ec2:DescribeInstanceAttribute",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeImages",
          "ec2:DescribeVolumes",
          "ec2:DescribeInstanceCreditSpecifications",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
      },
      {
        Sid    = "SecurityGroups"
        Effect = "Allow"
        Action = [
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupEgress"
        ]
        Resource = "*"
      },
      {
        Sid    = "KeyPairs"
        Effect = "Allow"
        Action = [
          "ec2:ImportKeyPair",
          "ec2:DeleteKeyPair"
        ]
        Resource = "*"
      },
      {
        Sid    = "CreateBucket"
        Effect = "Allow"
        Action = [
          "s3:CreateBucket"
        ]
        Resource = "*"
      },
      {
        Sid    = "ManageBucket"
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = "arn:aws:s3:::supanova-staging"
      },
      {
        Sid    = "ManagePolicy"
        Effect = "Allow"
        Action = [
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicies",
          "iam:ListPolicyVersions",
          "iam:ListAttachedUserPolicies",
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:AttachUserPolicy",
          "iam:DetachUserPolicy",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy"
        ]
        Resource = "*"
      },
      {
        Sid    = "CreateS3UserOnly"
        Effect = "Allow"
        Action = "iam:CreateUser"
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:UserName" = "supanova-staging-s3-bucket-user"
          }
        }
      },
      {
        Sid    = "ManageS3UserOnly"
        Effect = "Allow"
        Action = [
          "iam:DeleteUser",
          "iam:GetUser",
          "iam:ListGroupsForUser",
          "iam:CreateAccessKey",
          "iam:ListAccessKeys",
          "iam:DeleteAccessKey"
        ]
        Resource = "arn:aws:iam::839342898273:user/supanova-staging-s3-bucket-user"
      },
      {
        Sid    = "SSMParameterRead",
        Effect = "Allow",
        Action = [
          "ssm:GetParameter"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach policy to the user
resource "aws_iam_user_policy_attachment" "infra_user_attach" {
  user       = aws_iam_user.supanova_infra_staging_user.name
  policy_arn = aws_iam_policy.supanova_infra_staging_policy.arn
}

# Create an access key for the user
resource "aws_iam_access_key" "supanova_infra_staging_user_key" {
  user = aws_iam_user.supanova_infra_staging_user.name
}
