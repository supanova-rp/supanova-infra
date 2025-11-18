# ---------- S3 Bucket ----------
resource "aws_s3_bucket" "supanova-staging" {
  bucket = "supanova-staging"
}

# ---------- IAM User ----------
resource "aws_iam_user" "supanova-staging-s3" {
  name = "supanova-staging-s3-bucket-user"
}

# ---------- IAM Policy for S3 Access ----------
data "aws_iam_policy_document" "supanova_staging_bucket_access" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      aws_s3_bucket.supanova-staging.arn,
      "${aws_s3_bucket.supanova-staging.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "supanova_staging_bucket_policy" {
  name        = "supanova_staging_bucket_policy"
  description = "Policy to allow access to the supanova staging S3 bucket"
  policy      = data.aws_iam_policy_document.supanova_staging_bucket_access.json
}

# ---------- Attach Policy to User ----------
resource "aws_iam_user_policy_attachment" "attach_policy" {
  user       = aws_iam_user.supanova-staging-s3.name
  policy_arn = aws_iam_policy.supanova_staging_bucket_policy.arn
}

# ---------- Access Key for the User ----------
resource "aws_iam_access_key" "supanova_staging_s3_user_key" {
  user = aws_iam_user.supanova-staging-s3.name
}
