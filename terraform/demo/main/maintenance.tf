# Create S3 bucket for database backups
resource "aws_s3_bucket" "supanova_db_backup_demo" {
  bucket = "supanova-db-backup-demo"

  tags = {
    Name        = "supanova-db-backup-demo"
    Environment = "demo"
    Project     = "supanova"
  }
}

# Add lifecycle rule to auto-delete backups after 90 days
resource "aws_s3_bucket_lifecycle_configuration" "supanova_db_backup_demo_lifecycle" {
  bucket = aws_s3_bucket.supanova_db_backup_demo.id

  rule {
    id     = "delete-old-backups"
    status = "Enabled"

    filter {}

    expiration {
      days = 90
    }
  }
}

# Create IAM user
resource "aws_iam_user" "supanova_maintenance_demo" {
  name = "supanova-maintenance-demo"

  tags = {
    Environment = "demo"
    Project     = "supanova"
  }
}

# Create IAM policy
resource "aws_iam_policy" "supanova_maintenance_demo_policy" {
  name        = "supanova_maintenance_demo_policy"
  description = "Policy for supanova-maintenance-demo user to access S3 buckets"

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
          "arn:aws:s3:::supanova-demo",
          "arn:aws:s3:::supanova-demo/*"
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
          aws_s3_bucket.supanova_db_backup_demo.arn,
          "${aws_s3_bucket.supanova_db_backup_demo.arn}/*"
        ]
      }
    ]
  })
}

# Attach policy to user
resource "aws_iam_user_policy_attachment" "supanova_maintenance_demo_attachment" {
  user       = aws_iam_user.supanova_maintenance_demo.name
  policy_arn = aws_iam_policy.supanova_maintenance_demo_policy.arn
}

# Create access key for the user
resource "aws_iam_access_key" "supanova_maintenance_demo_key" {
  user = aws_iam_user.supanova_maintenance_demo.name
}

# Outputs
output "supanova_maintenance_demo_access_key_id" {
  description = "Access Key ID for supanova-maintenance-demo user"
  value       = aws_iam_access_key.supanova_maintenance_demo_key.id
}

output "supanova_maintenance_demo_access_key_secret" {
  description = "Secret Access Key for supanova-maintenance-demo user"
  value       = aws_iam_access_key.supanova_maintenance_demo_key.secret
  sensitive   = true
}
