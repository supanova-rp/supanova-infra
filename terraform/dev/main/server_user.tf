# Create IAM user
resource "aws_iam_user" "supanova_server_dev" {
  name = "supanova-server-dev"

  tags = {
    Environment = "dev"
  }
}

# Create IAM policy
resource "aws_iam_policy" "supanova_server_dev_policy" {
  name        = "supanova_server_dev_policy"
  description = "Policy for supanova-server-dev user"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ServerUserSupanovaDevS3Access"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${data.aws_s3_bucket.supanova_dev.arn}",
          "${data.aws_s3_bucket.supanova_dev.arn}/*"
        ]
      },
      {
        Sid = "ServerUserSupanovaDevSecretsAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:*:*:secret:supanova-dev-*"
        ]
      }
    ]
  })
}

# Attach policy to user
resource "aws_iam_user_policy_attachment" "supanova_server_dev_attachment" {
  user       = aws_iam_user.supanova_server_dev.name
  policy_arn = aws_iam_policy.supanova_server_dev_policy.arn
}

# Create access key for the user
resource "aws_iam_access_key" "supanova_server_dev_key" {
  user = aws_iam_user.supanova_server_dev.name
}

# Outputs
output "supanova_server_dev_access_key_id" {
  description = "Access Key ID for supanova-server-dev user"
  value       = aws_iam_access_key.supanova_server_dev_key.id
}

output "supanova_server_dev_access_key_secret" {
  description = "Secret Access Key for supanova-server-dev user"
  value       = aws_iam_access_key.supanova_server_dev_key.secret
  sensitive   = true
}
