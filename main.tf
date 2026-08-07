# main.tf for tf-module-cloudfront-website
resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_website_configuration" "s3_bucket_website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }
}

# Bucket policy to allow public read access
resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_website_distribution.arn
          }
        }
      }
    ]
  })
}

# Enable static website hosting
resource "aws_s3_bucket_public_access_block" "website_public_access_block_disable" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_cloudfront_distribution" "s3_website_distribution" {
  origin {
    domain_name              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id                = "${var.website_name}-S3-website"
    origin_access_control_id = aws_cloudfront_origin_access_control.website_oac.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.website_name} S3 CloudFront Distribution"
  default_root_object = var.index_document

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.website_name}-S3-website"

    cache_policy_id = aws_cloudfront_cache_policy.cloudfront_cache_policy.id

    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  aliases = var.website_aliases

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

resource "aws_cloudfront_cache_policy" "cloudfront_cache_policy" {
  name = "${var.website_name}-cache-policy"

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }

  default_ttl = 3600
  max_ttl     = 86400
  min_ttl     = 0
}

resource "aws_cloudfront_origin_access_control" "website_oac" {
  name                              = "${var.website_name}-oac"
  description                       = "OAC for accessing ${var.website_name} S3 bucket"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
  origin_access_control_origin_type = "s3"
}