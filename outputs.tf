# outputs.tf for tf-module-cloudfront-website
output "website_bucket_name" {
  description = "The name of the S3 bucket that hosts the website"
  value       = aws_s3_bucket.website_bucket.bucket
}

output "website_bucket_arn" {
  description = "The ARN of the S3 bucket that hosts the website"
  value       = aws_s3_bucket.website_bucket.arn
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution for the website"
  value       = aws_cloudfront_distribution.s3_website_distribution.id
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name of the CloudFront distribution for the website"
  value       = aws_cloudfront_distribution.s3_website_distribution.domain_name
}

output "s3_bucket_website_endpoint" {
  description = "The endpoint hosting the website on S3"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}