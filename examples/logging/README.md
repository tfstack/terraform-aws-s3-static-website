# S3 Static Website with Logging

This Terraform module creates an Amazon S3 bucket configured for static website hosting. It also includes optional logging configuration for monitoring and compliance.

---

## Features

- Creates an S3 bucket for static website hosting.
- Configures index and error documents.
- Supports versioning and public access controls.
- Optional logging for S3 to track access and usage.

---

## Example Usage

```hcl
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

  logging_config = {
    enable               = true
    enable_encryption    = true
    encryption_algorithm = "AES256"
    log_retention_days   = 30

    s3_prefix = "s3/"
  }

  tags = {
    Name = "s3-static-site-${random_string.suffix.result}"
  }
}

output "website_url" {
  value = module.s3_static_website.website_url
}

output "s3_website_url" {
  value = module.s3_static_website.s3_website_url
}
```

---

## Inputs

| Name                   | Description                                        | Type          | Default       |
|------------------------|----------------------------------------------------|---------------|---------------|
| `bucket_name`          | The base name of the S3 bucket.                    | `string`      | N/A           |
| `bucket_suffix`        | Optional suffix for the bucket name.               | `string`      | `""`          |
| `enable_versioning`    | Enable versioning for the S3 bucket.               | `bool`        | `false`       |
| `enable_force_destroy` | Force bucket deletion.                             | `bool`        | `false`       |
| `object_ownership`     | Defines bucket ownership.                          | `string`      | `"BucketOwnerPreferred"` |
| `index_document`       | The name of the index document.                    | `string`      | `"index.html"`|
| `error_document`       | The name of the error document.                    | `string`      | `"error.html"`|
| `source_file_path`     | Path to the local website files.                   | `string`      | N/A           |
| `allowed_principals`   | List of principals allowed access to the bucket.   | `list(string)`| `["*"]`       |
| `bucket_acl`           | ACL for the S3 bucket.                             | `string`      | `"private"`   |
| `public_access`        | Configuration for public access settings.          | `map(bool)`   | N/A           |
| `logging_config`       | Optional logging configuration.                    | `object`      | See Example   |
| `tags`                 | Tags to apply to the S3 bucket.                    | `map(string)` | `{}`          |

---

## Outputs

| Name                   | Description                                        |
|------------------------|----------------------------------------------------|
| `website_url`          | Dynamic website URL (S3 endpoint).                 |
| `s3_website_url`       | The endpoint URL of the S3 static website.         |

---

## Important Notes

- **S3 and Logging Configuration**:
  - Logging can be enabled to track access and usage of your S3 bucket.
  - Encryption ensures logs comply with security requirements.

- **Public Access**:
  - To make the website public, configure `public_access` and `bucket_acl` appropriately.

---

## License

MIT License. See `LICENSE` for more information.

---

## Author

Created by John Ajera. Contributions are welcome!
