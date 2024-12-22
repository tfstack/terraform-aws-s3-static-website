run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "setup_s3_static_website" {
  variables {
    s3_config = {
      bucket_name          = "test-s3-static-site"
      bucket_acl           = "public-read"
      bucket_suffix        = run.setup.suffix
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
      source_file_path   = "./tests/external"
      allowed_principals = ["*"]
    }

    tags = {
      Name = "test-s3-static-site-${run.setup.suffix}"
    }
  }

  assert {
    condition     = aws_s3_bucket_acl.this.acl == "public-read"
    error_message = "S3 bucket ACL is not set to 'public-read'"
  }

  assert {
    condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Enabled"
    error_message = "S3 bucket versioning is not enabled"
  }

  assert {
    condition     = aws_s3_bucket_website_configuration.this.index_document[0].suffix == "index.html"
    error_message = "Index document is not set to 'index.html'"
  }

  assert {
    condition     = aws_s3_bucket_website_configuration.this.error_document[0].key == "error.html"
    error_message = "Error document is not set to 'error.html'"
  }

  assert {
    condition     = aws_s3_bucket_ownership_controls.this.rule[0].object_ownership == "BucketOwnerPreferred"
    error_message = "Object ownership is not set to 'BucketOwnerPreferred'"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_acls == false
    error_message = "Block public acls is not set to 'false'"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_policy == false
    error_message = "Block public policy is not set to 'false'"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.ignore_public_acls == false
    error_message = "Ignore public acls is not set to 'false'"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.restrict_public_buckets == false
    error_message = "Restrict public buckets is not set to 'false'"
  }
}
