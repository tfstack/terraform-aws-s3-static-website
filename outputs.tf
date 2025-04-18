output "s3_bucket_id" {
  value       = aws_s3_bucket.this.id
  description = "The unique ID of the S3 bucket."
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.this.arn
  description = "The ARN of the S3 bucket."
}

output "s3_bucket_region" {
  value       = data.aws_region.current.name
  description = "The AWS region where the S3 bucket is deployed."
}

output "s3_bucket_domain_name" {
  value       = aws_s3_bucket.this.bucket_domain_name
  description = "The domain name of the S3 bucket (legacy global endpoint)."
}

output "s3_bucket_regional_domain_name" {
  value       = aws_s3_bucket.this.bucket_regional_domain_name
  description = "The regional domain name of the S3 bucket (recommended for CloudFront origins)."
}

output "s3_logging_bucket" {
  value       = var.logging_config.enable ? aws_s3_bucket.logging[0].id : null
  description = "The ID of the S3 bucket used for logging, if logging is enabled. Null if logging is disabled."
}

output "s3_website_url" {
  value       = "http://${aws_s3_bucket_website_configuration.this.website_endpoint}"
  description = "The HTTP URL of the S3 static website. Note: HTTPS is not natively supported by S3."
}

output "website_url" {
  value = (
    var.cdn_config.enable
    ? "https://${aws_route53_record.cloudfront[0].fqdn}"
    : "http://${aws_s3_bucket.this.bucket}.s3-website.${data.aws_region.current.name}.amazonaws.com"
  )
  description = "The dynamic website URL, using Route 53 custom domain if CDN is enabled, otherwise S3."
}

###############
# ACM

output "acm_certificate_arn" {
  value       = var.cdn_config.enable ? aws_acm_certificate.this[0].arn : null
  description = "The ARN of the ACM certificate used for the CloudFront distribution, if HTTPS is enabled."
}

###############
# CLOUDFRONT

output "cloudfront_distribution_id" {
  value       = var.cdn_config.enable ? aws_cloudfront_distribution.this[0].id : null
  description = "The ID of the CloudFront distribution, if CDN is enabled. Null if CDN is disabled."
}

output "cloudfront_distribution_arn" {
  value       = var.cdn_config.enable ? aws_cloudfront_distribution.this[0].arn : null
  description = "The ARN of the CloudFront distribution, if CDN is enabled. Null if CDN is disabled."
}

output "cloudfront_dns_name" {
  value       = var.cdn_config.enable ? aws_route53_record.cloudfront[0].fqdn : null
  description = "The DNS name for the CloudFront distribution, managed by Route 53, if CDN is enabled."
}

output "cloudfront_website_url" {
  value = (
    var.cdn_config.enable
    ? "https://${aws_cloudfront_distribution.this[0].domain_name}"
    : ""
  )
  description = "The website URL served through CloudFront when CDN is enabled. Empty if CDN is disabled."
}
