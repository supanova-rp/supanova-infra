# Create S3 bucket for database backups
resource "aws_s3_bucket" "supanova_db_backup_dev" {
  bucket = "supanova-db-backup-dev"

  tags = {
    Name        = "supanova-db-backup-dev"
    Environment = "dev"
  }
}

# Create IAM user
resource "aws_iam_user" "supanova_maintenance_dev" {
  name = "supanova-maintenance-dev"

  tags = {
    Environment = "dev"
  }
}

# Create IAM policy
resource "aws_iam_policy" "supanova_maintenance_dev_policy" {
  name        = "supanova_maintenance_dev_policy"
  description = "Policy for supanova-maintenance-dev user to access S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::supanova-dev",
          "arn:aws:s3:::supanova-dev/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.supanova_db_backup_dev.arn,
          "${aws_s3_bucket.supanova_db_backup_dev.arn}/*"
        ]
      }
    ]
  })
}

# Attach policy to user
resource "aws_iam_user_policy_attachment" "supanova_maintenance_dev_attachment" {
  user       = aws_iam_user.supanova_maintenance_dev.name
  policy_arn = aws_iam_policy.supanova_maintenance_dev_policy.arn
}

# Create access key for the user
resource "aws_iam_access_key" "supanova_maintenance_dev_key" {
  user = aws_iam_user.supanova_maintenance_dev.name
}

# Outputs
output "supanova_maintenance_access_key_id" {
  description = "Access Key ID for supanova-maintenance-dev user"
  value       = aws_iam_access_key.supanova_maintenance_dev_key.id
}

output "supanova_maintenance_access_key_secret" {
  description = "Secret Access Key for supanova-maintenance-dev user"
  value       = aws_iam_access_key.supanova_maintenance_dev_key.secret
  sensitive   = true
}
