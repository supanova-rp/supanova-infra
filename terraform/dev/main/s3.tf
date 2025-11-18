# Reference existing S3 Bucket
data "aws_s3_bucket" "supanova_dev" {
  bucket = "supanova-dev"
}

# Generate CloudFront public key
resource "aws_cloudfront_public_key" "supanova_dev" {
  name       = "supanova-dev-public-key"
  comment    = "Public key for supanova dev"
  encoded_key = file("./cloudfront_supanova_dev_public_key.pem")
}

# Link public key to a key group
resource "aws_cloudfront_key_group" "supanova_dev" {
  name = "supanova-dev-key-group"
  comment = "Key group for supanova dev"
  items = [aws_cloudfront_public_key.supanova_dev.id]
}

# CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "supanova_dev" {
  name                              = "supanova-dev-oac"
  description                       = "OAC for supanova_dev S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "supanova_dev" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "Distribution for supanova_dev media files"

  origin {
    domain_name              = data.aws_s3_bucket.supanova_dev.bucket_regional_domain_name
    origin_id                = "S3-supanova-dev"
    origin_access_control_id = aws_cloudfront_origin_access_control.supanova_dev.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-supanova-dev"

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
    trusted_key_groups = [aws_cloudfront_key_group.supanova_dev.id]
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
    Environment = "dev"
    Project     = "supanova"
  }
}

# S3 Bucket Policy to allow CloudFront access
resource "aws_s3_bucket_policy" "supanova_dev" {
  bucket = data.aws_s3_bucket.supanova_dev.id

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
        Resource = "${data.aws_s3_bucket.supanova_dev.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.supanova_dev.arn
          }
        }
      }
    ]
  })
}

# Outputs
output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.supanova_dev.id
}

output "cloudfront_distribution_domain" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.supanova_dev.domain_name
}

output "cloudfront_distribution_url" {
  description = "CloudFront distribution URL"
  value       = "https://${aws_cloudfront_distribution.supanova_dev.domain_name}"
}

output "cloudfront_public_key_id" {
  description = "CloudFront Public Key ID"
  value       = aws_cloudfront_public_key.supanova_dev.id
}