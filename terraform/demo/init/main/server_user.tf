# Create IAM user
resource "aws_iam_user" "supanova_server_demo" {
  name = "supanova-server-demo"

  tags = {
    Environment = "demo"
    Project     = "supanova"
  }
}

# Create IAM policy
resource "aws_iam_policy" "supanova_server_demo_policy" {
  name        = "supanova_server_demo_policy"
  description = "Policy for supanova-server-demo user"

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
          "${aws_s3_bucket.supanova_demo.arn}",
          "${aws_s3_bucket.supanova_demo.arn}/*"
        ]
      },
      {
        Sid    = "ServerUserSupanovaDevSecretsAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:*:*:secret:supanova-demo-*"
        ]
      }
    ]
  })
}

# Attach policy to user
resource "aws_iam_user_policy_attachment" "supanova_server_demo_attachment" {
  user       = aws_iam_user.supanova_server_demo.name
  policy_arn = aws_iam_policy.supanova_server_demo_policy.arn
}

# Create access key for the user
resource "aws_iam_access_key" "supanova_server_demo_key" {
  user = aws_iam_user.supanova_server_demo.name
}

# Outputs
output "supanova_server_demo_access_key_id" {
  description = "Access Key ID for supanova-server-demo user"
  value       = aws_iam_access_key.supanova_server_demo_key.id
}

output "supanova_server_demo_access_key_secret" {
  description = "Secret Access Key for supanova-server-demo user"
  value       = aws_iam_access_key.supanova_server_demo_key.secret
  sensitive   = true
}
