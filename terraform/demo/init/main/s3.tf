# Create S3 Bucket
resource "aws_s3_bucket" "supanova_demo" {
  bucket = "supanova-demo"

  tags = {
    Environment = "demo"
    Project     = "supanova"
  }
}

# Block public access on S3 bucket
resource "aws_s3_bucket_public_access_block" "supanova_demo" {
  bucket                  = aws_s3_bucket.supanova_demo.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Generate private key for cloudfront
resource "tls_private_key" "supanova_demo_cloudfront" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Attach private key to secret manager
# -----------------------------------------------------------
resource "aws_secretsmanager_secret" "supanova_demo_cloudfront_private_key" {
  name        = "supanova-demo-cloudfront-private-key"
  description = "CloudFront private key for signing supanova demo URLs"

  tags = {
    Environment = "demo"
    Project     = "supanova"
  }
}

resource "aws_secretsmanager_secret_version" "supanova_demo_cloudfront_private_key" {
  secret_id     = aws_secretsmanager_secret.supanova_demo_cloudfront_private_key.id
  secret_string = tls_private_key.supanova_demo_cloudfront.private_key_pem
}
# -----------------------------------------------------------

# Use the secret manager generated public key for CloudFront
resource "aws_cloudfront_public_key" "supanova_demo" {
  name        = "supanova-demo-public-key"
  comment     = "Public key for supanova demo"
  encoded_key = tls_private_key.supanova_demo_cloudfront.public_key_pem
}

# Link public key to a key group
resource "aws_cloudfront_key_group" "supanova_demo" {
  name    = "supanova-demo-key-group"
  comment = "Key group for supanova demo"
  items = [
    aws_cloudfront_public_key.supanova_demo.id,
    aws_cloudfront_public_key.supanova_demo.id
  ]
}

# CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "supanova_demo" {
  name                              = "supanova-demo-oac"
  description                       = "OAC for supanova_demo S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "supanova_demo" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "Distribution for supanova_demo media files"

  origin {
    domain_name              = aws_s3_bucket.supanova_demo.bucket_regional_domain_name
    origin_id                = "S3-supanova-demo"
    origin_access_control_id = aws_cloudfront_origin_access_control.supanova_demo.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-supanova-demo"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true

    # Require signed URLs
    trusted_key_groups = [aws_cloudfront_key_group.supanova_demo.id]
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Environment = "demo"
    Project     = "supanova"
  }
}

# S3 Bucket Policy to allow CloudFront access
resource "aws_s3_bucket_policy" "supanova_demo" {
  bucket = aws_s3_bucket.supanova_demo.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "Policy1675357809919"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.supanova_demo.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.supanova_demo.arn
          }
        }
      }
    ]
  })
}

# Outputs
output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.supanova_demo.id
}

output "cloudfront_distribution_domain" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.supanova_demo.domain_name
}

output "cloudfront_distribution_url" {
  description = "CloudFront distribution URL"
  value       = "https://${aws_cloudfront_distribution.supanova_demo.domain_name}"
}

output "cloudfront_public_key_id" {
  description = "CloudFront Public Key ID"
  value       = aws_cloudfront_public_key.supanova_demo.id
}
