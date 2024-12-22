# CloudFront CDN with S3 Static Website

This Terraform module creates an Amazon S3 bucket configured for static website hosting. It also integrates with CloudFront for global content delivery and Route 53 for custom domain configuration.

---

## Features

- Creates an S3 bucket for static website hosting.
- Configures index and error documents.
- Supports versioning and public access controls.
- Integrates with CloudFront for CDN.
- Optionally supports Route 53 for custom domain or subdomain configuration.
- Configures HTTPS with an ACM certificate.

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
| `public_access`        | Configuration for public access settings.          | `map(bool)`   | N/A           |
| `cdn_config`           | Optional CloudFront configuration.                 | `object`      | See Example   |
| `tags`                 | Tags to apply to the S3 bucket.                    | `map(string)` | `{}`          |

---

## Outputs

| Name                   | Description                                        |
|------------------------|----------------------------------------------------|
| `cloudfront_website_url` | The CloudFront distribution URL.                  |
| `website_url`          | Dynamic website URL (custom domain or S3 endpoint).|
| `s3_website_url`       | The endpoint URL of the S3 static website.         |

---

## Important Notes

- **Custom Domain with Route 53**:
  - If a custom domain is enabled, a Route 53 record is created for the specified domain and subdomain.
  - The `bucket_name` and `bucket_suffix` should be unique to avoid conflicts.

- **S3 and CloudFront Restrictions**:
  - The S3 bucket name and custom domain name do not need to match, but the domain configuration must correctly point to the S3 bucket's website endpoint.

- **Public Access**:
  - To make the website public, configure `public_access` and `bucket_acl` appropriately.

- **ACM Certificate Region**:
  - The ACM certificate **must be created in the `us-east-1` region** for CloudFront to validate and use it correctly. Ensure the ACM provider explicitly specifies this region.

---

## License

MIT License. See `LICENSE` for more information.

---

## Author

Created by John Ajera. Contributions are welcome!
