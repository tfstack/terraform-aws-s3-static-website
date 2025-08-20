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

  tags = {
    Name = "s3-static-site-${random_string.suffix.result}"
  }
}

# Create robots.txt directly in S3
resource "aws_s3_object" "robots_txt" {
  bucket       = module.s3_static_website.s3_bucket_id
  key          = "robots.txt"
  content      = "User-agent: *\nDisallow: /"
  content_type = "text/plain"

  tags = {
    Name      = "robots.txt"
    ManagedBy = "terraform"
    Purpose   = "robots-txt"
  }
}

output "website_url" {
  value = module.s3_static_website.website_url
}

output "s3_website_url" {
  value = module.s3_static_website.s3_website_url
}
