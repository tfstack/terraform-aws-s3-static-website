# terraform-aws-s3-static-website

Terraform module that deploys basic AWS S3 static website

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
| <a name="provider_aws.us_east_1"></a> [aws.us\_east\_1](#provider\_aws.us\_east\_1) | >= 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_distribution.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_route53_record.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.ssl_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_lifecycle_configuration.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_ownership_controls.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_website_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |
| [aws_s3_object.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

### S3 Configuration

- **`s3_config`**: Configuration for the S3 bucket, including naming, access controls, and website settings.
  - **Attributes**:
    - **`bucket_name`**: Base name of the S3 bucket (`string`, required). Must be DNS-compliant (lowercase, numbers, hyphens only, and combined with `bucket_suffix` must not exceed 63 characters).
    - **`bucket_acl`**: Access control list for the S3 bucket (`string`, default: `"private"`). Allowed values: `"private"`, `"public-read"`.
    - **`bucket_suffix`**: Optional suffix for the bucket name (`string`, default: `""`). Must not exceed 16 characters.
    - **`enable_force_destroy`**: Force deletion of the bucket (`bool`, default: `false`).
    - **`object_ownership`**: Defines bucket ownership (`string`, default: `"BucketOwnerPreferred"`). Allowed values: `"BucketOwnerPreferred"`, `"ObjectWriter"`, `"BucketOwnerEnforced"`.
    - **`enable_versioning`**: Enable versioning for the bucket (`bool`, default: `false`).
    - **`index_document`**: Name of the index document (`string`, default: `"index.html"`). Cannot be empty.
    - **`error_document`**: Name of the error document (`string`, default: `""`).
    - **`public_access`**: Public access configuration for the bucket (`object`):
      - **`block_public_acls`**: Block public ACLs (`bool`, default: `true`).
      - **`block_public_policy`**: Block public bucket policies (`bool`, default: `true`).
      - **`ignore_public_acls`**: Ignore public ACLs (`bool`, default: `true`).
      - **`restrict_public_buckets`**: Restrict public buckets (`bool`, default: `true`).
    - **`source_file_path`**: Path to the local website files (`string`, default: `"/var/www"`). Cannot be empty.
    - **`allowed_principals`**: List of principals allowed access to the bucket (`list(string)`, default: `["*"]`). Must contain at least one principal.

---

### CDN Configuration

- **`cdn_config`**: Settings for enabling HTTPS, CloudFront, ACM, and optional custom domain configurations.
  - **Attributes**:
    - **`enable`**: Enable or disable CDN. When `false`, CloudFront-related outputs will be `null` (`bool`, default: `false`).
    - **`domain`**: Domain settings for the CDN (`object`).
      - **`name`**: Root domain name (`string`, default: `""`). Must be DNS-compliant.
      - **`sub_name`**: Subdomain name (`string`, default: `""`). Must be DNS-compliant.
      - **`ttl`**: Time-to-live for DNS records (`number`, default: `300`).
    - **`validation_method`**: ACM validation method (`string`, default: `"DNS"`).
    - **`origin_access_comment`**: Comment for the CloudFront origin access identity (`string`, default: `"Access Identity for S3 Origin"`).
    - **`allowed_methods`**: Allowed HTTP methods (`list(string)`, default: `["GET", "HEAD", "OPTIONS"]`). Must contain at least one method.
    - **`cached_methods`**: Cached HTTP methods (`list(string)`, default: `["GET", "HEAD"]`). Must contain at least one method.
    - **`enable_compression`**: Enable HTTP compression (`bool`, default: `true`).
    - **`protocol_policy`**: CloudFront protocol policy (`string`, default: `"redirect-to-https"`). Allowed values: `"allow-all"`, `"redirect-to-https"`, `"https-only"`.
    - **`forward_query_string`**: Forward query strings to the origin (`bool`, default: `false`).
    - **`forward_cookies`**: Cookie forwarding policy (`string`, default: `"none"`).
    - **`minimum_ttl`**: Minimum TTL for objects (`number`, default: `0`). Must be greater than or equal to `0`.
    - **`default_ttl`**: Default TTL for objects (`number`, default: `300`). Must be greater than or equal to `minimum_ttl`.
    - **`maximum_ttl`**: Maximum TTL for objects (`number`, default: `1200`). Must be greater than or equal to `default_ttl`.
    - **`price_class`**: CloudFront price class (`string`, default: `"PriceClass_All"`). Allowed values: `"PriceClass_All"`, `"PriceClass_200"`, `"PriceClass_100"`.
    - **`error_page_path`**: Path for custom error pages (`string`, default: `"/error.html"`).
    - **`error_page_cache_ttl`**: TTL for caching error pages (`number`, default: `300`).
    - **`ssl_support_method`**: SSL support method for CloudFront (`string`, default: `"sni-only"`). Allowed values: `"sni-only"`, `"vip"`.
    - **`minimum_tls_version`**: Minimum TLS version for HTTPS (`string`, default: `"TLSv1.2_2021"`). Allowed values: `"SSLv3"`, `"TLSv1"`, `"TLSv1.1"`, `"TLSv1.2"`, `"TLSv1.2_2018"`, `"TLSv1.2_2021"`.
    - **`geo_restriction_policy`**: Geo-restriction policy (`string`, default: `"none"`). Allowed values: `"none"`, `"whitelist"`, `"blacklist"`.

---

### Logging Configuration

- **`logging_config`**: Configuration for S3 bucket logging.
  - **Attributes**:
    - **`enable`**: Enable or disable logging. When `false`, `s3_logging_bucket` output will be `null` (`bool`, default: `false`).
    - **`s3_prefix`**: Prefix for logging files in S3 (`string`, default: `"s3/"`). Must be a valid string.
    - **`cloudfront_prefix`**: Prefix for CloudFront logs in S3 (`string`, default: `"cloudfront/"`). Must be a valid string.
    - **`log_retention_days`**: Retention period for logs (`number`, default: `30`).
    - **`enable_encryption`**: Enable encryption for logs (`bool`, default: `true`).
    - **`encryption_algorithm`**: Algorithm for log encryption (`string`, default: `"AES256"`).

---

### Tags

- **`tags`**: Map of tags to assign to the resources (`map(string)`, default: `{}`).

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_certificate_arn"></a> [acm\_certificate\_arn](#output\_acm\_certificate\_arn) | The ARN of the ACM certificate used for the CloudFront distribution, if HTTPS is enabled. |
| <a name="output_cloudfront_distribution_arn"></a> [cloudfront\_distribution\_arn](#output\_cloudfront\_distribution\_arn) | The ARN of the CloudFront distribution, if CDN is enabled. Null if CDN is disabled. |
| <a name="output_cloudfront_distribution_id"></a> [cloudfront\_distribution\_id](#output\_cloudfront\_distribution\_id) | The ID of the CloudFront distribution, if CDN is enabled. Null if CDN is disabled. |
| <a name="output_cloudfront_dns_name"></a> [cloudfront\_dns\_name](#output\_cloudfront\_dns\_name) | The DNS name for the CloudFront distribution, managed by Route 53, if CDN is enabled. |
| <a name="output_cloudfront_website_url"></a> [cloudfront\_website\_url](#output\_cloudfront\_website\_url) | The website URL served through CloudFront when CDN is enabled. Empty if CDN is disabled. |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | The ARN of the S3 bucket. |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | The unique ID of the S3 bucket. |
| <a name="output_s3_bucket_region"></a> [s3\_bucket\_region](#output\_s3\_bucket\_region) | The AWS region where the S3 bucket is deployed. |
| <a name="output_s3_logging_bucket"></a> [s3\_logging\_bucket](#output\_s3\_logging\_bucket) | The ID of the S3 bucket used for logging, if logging is enabled. Null if logging is disabled. |
| <a name="output_s3_website_url"></a> [s3\_website\_url](#output\_s3\_website\_url) | The HTTP URL of the S3 static website. Note: HTTPS is not natively supported by S3. |
| <a name="output_website_url"></a> [website\_url](#output\_website\_url) | The dynamic website URL, using Route 53 custom domain if CDN is enabled, otherwise S3. |
