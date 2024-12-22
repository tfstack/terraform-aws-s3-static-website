provider "aws" {
  region = "ap-southeast-2"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

module "s3_static_website" {
  source = "../.."

  s3_config = {
    bucket_name          = "private-s3-static-website"
    bucket_acl           = "private"
    bucket_suffix        = random_string.suffix.result
    enable_force_destroy = true
    object_ownership     = "BucketOwnerPreferred"
    enable_versioning    = true
    index_document       = "index.html"
    error_document       = "error.html"
    public_access = {
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
    }
    source_file_path   = "${path.module}/external"
    allowed_principals = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
  }

  tags = {
    Name = "private-s3-static-website-${random_string.suffix.result}"
  }
}

output "website_url" {
  value = module.s3_static_website.website_url
}

output "s3_website_url" {
  value = module.s3_static_website.s3_website_url
}

output "presign_test_command" {
  value = "curl $(aws s3 presign s3://${module.s3_static_website.s3_bucket_id}/index.html --region ${data.aws_region.current.name})"
}
