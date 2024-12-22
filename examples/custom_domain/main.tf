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

  bucket_name   = "s3-static-site"
  bucket_suffix = random_string.suffix.result

  enable_versioning    = true
  enable_force_destroy = true
  object_ownership     = "BucketOwnerPreferred"

  index_document   = "index.html"
  error_document   = "error.html"
  source_file_path = "${path.module}/external"

  allowed_principals = ["*"]
  bucket_acl         = "public-read"

  public_access_config = {
    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
  }

  custom_domain = {
    enable = true
    domain = "example.com"
    name   = "web"
    ttl    = 300
  }

  tags = {
    Name = "s3-static-site-${random_string.suffix.result}"
  }
}

output "s3_bucket_id" {
  value = module.s3_static_website.s3_bucket_id
}

output "s3_bucket_arn" {
  value = module.s3_static_website.s3_bucket_arn
}

output "s3_website_endpoint" {
  value = module.s3_static_website.s3_website_endpoint
}

output "website_url" {
  value = module.s3_static_website.website_url
}
