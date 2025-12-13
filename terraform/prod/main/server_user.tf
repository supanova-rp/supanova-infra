# Create IAM user
resource "aws_iam_user" "supanova_server_prod" {
  name = "supanova-server-prod"

  tags = {
    Environment = "production"
    Project     = "supanova"
  }
}

# Create IAM policy
resource "aws_iam_policy" "supanova_server_prod_policy" {
  name        = "supanova_server_prod_policy"
  description = "Policy for supanova-server-prod user"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ServerUserSupanovaProdS3Access"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.supanova_prod.arn}",
          "${aws_s3_bucket.supanova_prod.arn}/*"
        ]
      },
      {
        Sid    = "ServerUserSupanovaProdSecretsAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:*:*:secret:supanova-prod-*"
        ]
      }
    ]
  })
}

# Attach policy to user
resource "aws_iam_user_policy_attachment" "supanova_server_prod_attachment" {
  user       = aws_iam_user.supanova_server_prod.name
  policy_arn = aws_iam_policy.supanova_server_prod_policy.arn
}

# Create access key for the user
resource "aws_iam_access_key" "supanova_server_prod_key" {
  user = aws_iam_user.supanova_server_prod.name
}

# Outputs
output "supanova_server_prod_access_key_id" {
  description = "Access Key ID for supanova-server-prod user"
  value       = aws_iam_access_key.supanova_server_prod_key.id
}

output "supanova_server_prod_access_key_secret" {
  description = "Secret Access Key for supanova-server-prod user"
  value       = aws_iam_access_key.supanova_server_prod_key.secret
  sensitive   = true
}
