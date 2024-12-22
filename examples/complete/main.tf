provider "aws" {
  region = "ap-southeast-2"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

module "s3_static_website" {
  source = "../.."

  s3_config = {
    bucket_name          = "s3-static-site"
    bucket_acl           = "public-read"
    bucket_suffix        = random_string.suffix.result
    enable_force_destroy = true
    object_ownership     = "BucketOwnerPreferred"
    enable_versioning    = true
    index_document       = "index.html"
    error_document       = "error.html"
    public_access = {
      block_public_acls       = false
      block_public_policy     = false
      ignore_public_acls      = false
      restrict_public_buckets = false
    }
    source_file_path   = "${path.module}/external"
    allowed_principals = ["*"]
  }

  cdn_config = {
    enable = true
    domain = {
      name     = "example.com"
      sub_name = "web"
      ttl      = 300
    }
    validation_method      = "DNS"
    origin_access_comment  = "Access Identity for S3 Origin"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    enable_compression     = true
    protocol_policy        = "redirect-to-https"
    forward_query_string   = false
    forward_cookies        = "none"
    minimum_ttl            = 0
    default_ttl            = 300
    maximum_ttl            = 1200
    price_class            = "PriceClass_All"
    error_page_path        = "/error.html"
    error_page_cache_ttl   = 300
    ssl_support_method     = "sni-only"
    minimum_tls_version    = "TLSv1.2_2021"
    geo_restriction_policy = "none"
  }

  logging_config = {
    enable               = true
    enable_encryption    = true
    encryption_algorithm = "AES256"
    log_retention_days   = 30

    s3_prefix         = "s3/"
    cloudfront_prefix = "cloudfront/"
  }

  tags = {
    Name = "s3-static-site-${random_string.suffix.result}"
  }
}

output "cloudfront_website_url" {
  value = module.s3_static_website.cloudfront_website_url
}

output "website_url" {
  value = module.s3_static_website.website_url
}

output "s3_website_url" {
  value = module.s3_static_website.s3_website_url
}
