# S3 Static Website (Public Access)

This Terraform module creates an Amazon S3 bucket configured for static website hosting with public access.

---

## Features

- Creates an S3 bucket for static website hosting.
- Configures index and error documents.
- Supports versioning and public access controls.

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
  source = "tfstack/s3-static-website/aws"

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
| `bucket_acl`           | ACL for the S3 bucket.                             | `string`      | `"public-read"`|
| `public_access`        | Configuration for public access settings.          | `map(bool)`   | N/A           |
| `tags`                 | Tags to apply to the S3 bucket.                    | `map(string)` | `{}`          |

---

## Outputs

| Name                   | Description                                        |
|------------------------|----------------------------------------------------|
| `website_url`          | Dynamic website URL (S3 endpoint).                 |
| `s3_website_url`       | The endpoint URL of the S3 static website.         |

---

## Important Notes

- **Public Access Configuration**:
  - This configuration ensures the S3 bucket is publicly accessible.
  - Adjust `public_access` and `bucket_acl` settings based on your requirements.

- **Static Website Hosting**:
  - The bucket serves static files as a website with the specified index and error documents.

---

## License

MIT License. See `LICENSE` for more information.

---

## Author

Created by John Ajera. Contributions are welcome!
