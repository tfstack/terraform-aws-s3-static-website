# S3 Static Website (Private Access)

This Terraform module creates an Amazon S3 bucket configured for static website hosting with private access.

---

## Features

- Creates an S3 bucket for static website hosting.
- Configures index and error documents.
- Supports versioning and strict access controls for private access.

---

## Example Usage

```hcl
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
| `allowed_principals`   | List of principals allowed access to the bucket.   | `list(string)`| `[]`          |
| `bucket_acl`           | ACL for the S3 bucket.                             | `string`      | `"private"`   |
| `public_access`        | Configuration for public access settings.          | `map(bool)`   | N/A           |
| `tags`                 | Tags to apply to the S3 bucket.                    | `map(string)` | `{}`          |

---

## Outputs

| Name                   | Description                                        |
|------------------------|----------------------------------------------------|
| `website_url`          | Dynamic website URL (S3 endpoint).                 |
| `s3_website_url`       | The endpoint URL of the S3 static website.         |
| `presign_test_command` | Command to test private access to the bucket.      |

---

## Important Notes

- **S3 Access Configuration**:
  - This configuration ensures strict private access to the S3 bucket.
  - Principals allowed access can be specified in `allowed_principals`.

- **Presigned URL Testing**:
  - The output `presign_test_command` provides a command to test access to private files.
  - Use this command to validate access since private files cannot be directly browsed in a browser.

---

## License

MIT License. See `LICENSE` for more information.

---

## Author

Created by John Ajera. Contributions are welcome!
