# terraform-aws-s3-static-website

Terraform module that deploys basic AWS S3 static website

<!-- BEGIN_TF_DOCS -->
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

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cdn_config"></a> [cdn\_config](#input\_cdn\_config) | Settings for enabling HTTPS, CloudFront, ACM, and optional custom domain configurations. | <pre>object({<br/>    enable = bool<br/>    domain = object({<br/>      name     = string<br/>      sub_name = string<br/>      ttl      = optional(number, 300)<br/>    })<br/>    validation_method      = optional(string, "DNS")<br/>    origin_access_comment  = optional(string, "Access Identity for S3 Origin")<br/>    allowed_methods        = optional(list(string), ["GET", "HEAD", "OPTIONS"])<br/>    cached_methods         = optional(list(string), ["GET", "HEAD"])<br/>    enable_compression     = optional(bool, true)<br/>    protocol_policy        = optional(string, "redirect-to-https")<br/>    forward_query_string   = optional(bool, false)<br/>    forward_cookies        = optional(string, "none")<br/>    minimum_ttl            = optional(number, 0)<br/>    default_ttl            = optional(number, 300)<br/>    maximum_ttl            = optional(number, 1200)<br/>    price_class            = optional(string, "PriceClass_All")<br/>    error_page_path        = optional(string, "/error.html")<br/>    error_page_cache_ttl   = optional(number, 300)<br/>    ssl_support_method     = optional(string, "sni-only")<br/>    minimum_tls_version    = optional(string, "TLSv1.2_2021")<br/>    geo_restriction_policy = optional(string, "none")<br/>  })</pre> | <pre>{<br/>  "allowed_methods": [<br/>    "GET",<br/>    "HEAD",<br/>    "OPTIONS"<br/>  ],<br/>  "cached_methods": [<br/>    "GET",<br/>    "HEAD"<br/>  ],<br/>  "default_ttl": 300,<br/>  "domain": {<br/>    "name": "",<br/>    "sub_name": "",<br/>    "ttl": 300<br/>  },<br/>  "enable": false,<br/>  "enable_compression": true,<br/>  "error_page_cache_ttl": 300,<br/>  "error_page_path": "/error.html",<br/>  "forward_cookies": "none",<br/>  "forward_query_string": false,<br/>  "geo_restriction_policy": "none",<br/>  "maximum_ttl": 1200,<br/>  "minimum_tls_version": "TLSv1.2_2021",<br/>  "minimum_ttl": 0,<br/>  "origin_access_comment": "Access Identity for S3 Origin",<br/>  "price_class": "PriceClass_All",<br/>  "protocol_policy": "redirect-to-https",<br/>  "ssl_support_method": "sni-only",<br/>  "validation_method": "DNS"<br/>}</pre> | no |
| <a name="input_logging_config"></a> [logging\_config](#input\_logging\_config) | Configuration for S3 bucket logging. | <pre>object({<br/>    enable               = bool<br/>    s3_prefix            = optional(string, "s3/")<br/>    cloudfront_prefix    = optional(string, "cloudfront/")<br/>    log_retention_days   = optional(number, 30)<br/>    enable_encryption    = optional(bool, true)<br/>    encryption_algorithm = optional(string, "AES256")<br/>  })</pre> | <pre>{<br/>  "cloudfront_prefix": "cloudfront/",<br/>  "enable": false,<br/>  "enable_encryption": true,<br/>  "encryption_algorithm": "AES256",<br/>  "log_retention_days": 90,<br/>  "s3_prefix": "s3/"<br/>}</pre> | no |
| <a name="input_s3_config"></a> [s3\_config](#input\_s3\_config) | Configuration for the S3 bucket, including naming, access controls, and website settings. | <pre>object({<br/>    bucket_name          = optional(string, "s3-static-site")<br/>    bucket_acl           = optional(string, "private")<br/>    bucket_suffix        = optional(string, "")<br/>    enable_force_destroy = optional(bool, false)<br/>    object_ownership     = optional(string, "BucketOwnerPreferred")<br/>    enable_versioning    = optional(bool, false)<br/>    index_document       = optional(string, "index.html")<br/>    error_document       = optional(string, "")<br/>    public_access = object({<br/>      block_public_acls       = optional(bool, true)<br/>      block_public_policy     = optional(bool, true)<br/>      ignore_public_acls      = optional(bool, true)<br/>      restrict_public_buckets = optional(bool, true)<br/>    })<br/>    source_file_path   = optional(string, "/var/www")<br/>    allowed_principals = optional(list(string), ["*"])<br/>  })</pre> | <pre>{<br/>  "allowed_principals": [<br/>    "*"<br/>  ],<br/>  "bucket_acl": "private",<br/>  "bucket_name": "s3-static-site",<br/>  "bucket_suffix": "",<br/>  "enable_force_destroy": false,<br/>  "enable_versioning": false,<br/>  "error_document": "",<br/>  "index_document": "index.html",<br/>  "object_ownership": "BucketOwnerPreferred",<br/>  "public_access": {<br/>    "block_public_acls": true,<br/>    "block_public_policy": true,<br/>    "ignore_public_acls": true,<br/>    "restrict_public_buckets": true<br/>  },<br/>  "source_file_path": "/var/www"<br/>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resources. Tags are useful for identifying and managing resources in AWS. If no tags are provided, an empty map will be used. | `map(string)` | `{}` | no |

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
<!-- END_TF_DOCS -->
