# CloudFront Website Terraform Module

This Terraform module creates a complete static website hosting solution using AWS S3 and CloudFront. It provides a secure, scalable, and performant infrastructure for hosting static websites with HTTPS support, custom domains, and CloudFront CDN distribution.

## Features

- Creates an S3 bucket configured for static website hosting
- Sets up CloudFront distribution with Origin Access Control (OAC) for secure S3 access
- Configures custom cache policies for optimized content delivery
- Supports custom domain names (aliases) with ACM certificates
- Enforces HTTPS with redirect from HTTP
- Configurable index and error documents
- Geo-restriction capabilities
- IPv6 support enabled by default

## Usage

```hcl
module "cloudfront_website" {
  source = "git::https://github.com/ZhangMaKe/tf-module-cloudfront-website.git"

  # Website Configuration
  website_name = "my-awesome-website"
  bucket_name  = "my-awesome-website-bucket"
  
  # Optional: Custom documents
  index_document = "index.html"
  error_document = "error.html"
  
  # Custom Domain Configuration
  website_aliases = [
    "www.example.com",
    "example.com"
  ]
  
  # ACM Certificate (must be in us-east-1 for CloudFront)
  certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abc123..."
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| website_name | The name of the website | `string` | n/a | yes |
| bucket_name | The name of the S3 bucket that will host website | `string` | n/a | yes |
| index_document | The website for the index document (e.g., home page) | `string` | `"index.html"` | no |
| error_document | The website for the error document (e.g., 404 page) | `string` | `"index.html"` | no |
| website_aliases | The list of aliases (alternate domain names) for the website | `list(string)` | `[]` | no |
| certificate_arn | The ARN of the ACM certificate for the website | `string` | n/a | yes |

## Outputs

The module outputs the following attributes:

- **website_bucket_name**: The name of the S3 bucket that hosts the website
- **website_bucket_arn**: The ARN of the S3 bucket that hosts the website
- **cloudfront_distribution_id**: The ID of the CloudFront distribution for the website
- **cloudfront_distribution_domain_name**: The domain name of the CloudFront distribution for the website
- **s3_bucket_website_endpoint**: The endpoint hosting the website on S3

## Requirements

- Terraform >= 0.13
- AWS Provider
- An ACM certificate in us-east-1 region (required for CloudFront)
- DNS configuration to point custom domains to CloudFront distribution

## Important Notes

1. **ACM Certificate**: The ACM certificate must be created in the `us-east-1` region to be used with CloudFront, regardless of where your S3 bucket is located.

2. **DNS Configuration**: After creating the CloudFront distribution, you need to configure your DNS to point your custom domains to the CloudFront distribution domain name (available as an output).

3. **Content Deployment**: This module creates the infrastructure only. You'll need to separately upload your website files to the S3 bucket.


## Example: Complete Website Deployment

```hcl
# Request ACM certificate (must be in us-east-1 for CloudFront)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_acm_certificate" "website_cert" {
  provider          = aws.us_east_1
  domain_name       = "example.com"
  validation_method = "DNS"
  
  subject_alternative_names = ["www.example.com"]
  
  lifecycle {
    create_before_destroy = true
  }
}

module "cloudfront_website" {
  source = "git::https://github.com/ZhangMaKe/tf-module-cloudfront-website.git"

  website_name    = "my-website"
  bucket_name     = "my-website-bucket-unique-name"
  website_aliases = ["example.com", "www.example.com"]
  certificate_arn = aws_acm_certificate.website_cert.arn
}

# Upload website files
resource "aws_s3_object" "website_files" {
  for_each = fileset("${path.module}/website", "**")
  
  bucket       = module.cloudfront_website.website_bucket_name
  key          = each.value
  source       = "${path.module}/website/${each.value}"
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
  etag         = filemd5("${path.module}/website/${each.value}")
}

# Configure Route53 DNS
resource "aws_route53_record" "website" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "example.com"
  type    = "A"

  alias {
    name                   = module.cloudfront_website.cloudfront_distribution_domain_name
    zone_id                = "Z2FDTNDATAQYW2" # CloudFront hosted zone ID
    evaluate_target_health = false
  }
}
```

## License

This module is released under the MIT License.
