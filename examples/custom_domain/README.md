# S3 Static Website Terraform Module (Custom Domain)

This Terraform module creates an Amazon S3 bucket configured for static website hosting. It also integrates with Route 53 for custom domain configuration.

---

## Features

- Creates an S3 bucket for static website hosting.
- Configures index and error documents.
- Supports versioning and public access controls.
- Integrates with Route 53 for custom domain or subdomain configuration.
- Automatically detects and sets up Route 53 records if enabled.

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
    name   = "example.com"
    ttl    = 300
  }

  tags = {
    Name = "s3-static-site-${random_string.suffix.result}"
  }
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
| `public_access_config` | Configuration for public access settings.          | `map(bool)`   | N/A           |
| `custom_domain`        | Optional custom domain configuration.              | `object`      | See Example   |
| `tags`                 | Tags to apply to the S3 bucket.                    | `map(string)` | `{}`          |

---

## Outputs

| Name                   | Description                                        |
|------------------------|----------------------------------------------------|
| `s3_bucket_id`         | The ID of the S3 bucket.                           |
| `s3_bucket_arn`        | The ARN of the S3 bucket.                          |
| `s3_website_endpoint`  | The endpoint URL of the S3 static website.         |
| `website_url`          | Dynamic website URL (custom domain or S3 endpoint).|

---

## Important Notes

- **Custom Domain with Route 53**:
  - If a custom domain is enabled, a Route 53 record is created for the specified domain and subdomain.
  - The `bucket_name` and `bucket_suffix` should be unique to avoid conflicts.

- **S3 and Route 53 Restrictions**:
  - The S3 bucket name and custom domain name do not need to match, but the domain configuration must correctly point to the S3 bucket's website endpoint.
  - Subdomain configurations are supported with CNAME records.

- **Public Access**:
  - To make the website public, configure `public_access_config` and `bucket_acl` appropriately.

---

## License

MIT License. See `LICENSE` for more information.

---

## Author

Created by John Ajera. Contributions are welcome!
