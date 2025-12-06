# Reference existing S3 Bucket
data "aws_s3_bucket" "supanova_prod" {
  bucket = "supanova-prod"
}

# Generate private key for cloudfront
resource "tls_private_key" "supanova_prod_cloudfront" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Attach private key to secret manager
# -----------------------------------------------------------
resource "aws_secretsmanager_secret" "supanova_prod_cloudfront_private_key_v2" {
  name        = "supanova-prod-cloudfront-private-key-v2"
  description = "CloudFront private key for signing supanova prod URLs"
  
  tags = {
    Environment = "production"
    Project     = "supanova"
  }
}

resource "aws_secretsmanager_secret_version" "supanova_prod_cloudfront_private_key_v2" {
  secret_id     = aws_secretsmanager_secret.supanova_prod_cloudfront_private_key_v2.id
  secret_string = tls_private_key.supanova_prod_cloudfront.private_key_pem
}
# -----------------------------------------------------------

# Use the secret manager generated public key for CloudFront
resource "aws_cloudfront_public_key" "supanova_prod_v2" {
  name        = "supanova-prod-public-key-v2"
  comment     = "Public key for supanova prod"
  encoded_key = tls_private_key.supanova_prod_cloudfront.public_key_pem
}

# Use CloudFront public key file (legacy one, will be removed when no longer in use)
resource "aws_cloudfront_public_key" "supanova_prod" {
  name       = "supanova-prod-public-key"
  comment    = "Public key for supanova prod (legacy version)"
  encoded_key = file("./cloudfront_supanova_prod_public_key.pem")
}

# Link public key to a key group
resource "aws_cloudfront_key_group" "supanova_prod" {
  name = "supanova-prod-key-group"
  comment = "Key group for supanova prod"
  items = [
    aws_cloudfront_public_key.supanova_prod_v2.id,
    aws_cloudfront_public_key.supanova_prod.id
  ]
}

# CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "supanova_prod" {
  name                              = "supanova-prod-oac"
  description                       = "OAC for supanova_prod S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "supanova_prod" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "Distribution for supanova_prod media files"

  origin {
    domain_name              = data.aws_s3_bucket.supanova_prod.bucket_regional_domain_name
    origin_id                = "S3-supanova-prod"
    origin_access_control_id = aws_cloudfront_origin_access_control.supanova_prod.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-supanova-prod"

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
    trusted_key_groups = [aws_cloudfront_key_group.supanova_prod.id]
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
    Environment = "production"
    Project     = "supanova"
  }
}

# S3 Bucket Policy to allow CloudFront access
resource "aws_s3_bucket_policy" "supanova_prod" {
  bucket = data.aws_s3_bucket.supanova_prod.id

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
        Resource = "${data.aws_s3_bucket.supanova_prod.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.supanova_prod.arn
          }
        }
      }
    ]
  })
}

# Outputs
output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.supanova_prod.id
}

output "cloudfront_distribution_domain" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.supanova_prod.domain_name
}

output "cloudfront_distribution_url" {
  description = "CloudFront distribution URL"
  value       = "https://${aws_cloudfront_distribution.supanova_prod.domain_name}"
}

output "cloudfront_public_key_id_legacy" {
  description = "CloudFront Public Key ID (legacy)"
  value       = aws_cloudfront_public_key.supanova_prod.id
}

output "cloudfront_public_key_id_v2" {
  description = "CloudFront Public Key ID (v2)"
  value       = aws_cloudfront_public_key.supanova_prod_v2.id
}
