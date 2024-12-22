variable "s3_config" {
  description = "Configuration for the S3 bucket, including naming, access controls, and website settings."
  type = object({
    bucket_name          = optional(string, "s3-static-site")
    bucket_acl           = optional(string, "private")
    bucket_suffix        = optional(string, "")
    enable_force_destroy = optional(bool, false)
    object_ownership     = optional(string, "BucketOwnerPreferred")
    enable_versioning    = optional(bool, false)
    index_document       = optional(string, "index.html")
    error_document       = optional(string, "")
    public_access = object({
      block_public_acls       = optional(bool, true)
      block_public_policy     = optional(bool, true)
      ignore_public_acls      = optional(bool, true)
      restrict_public_buckets = optional(bool, true)
    })
    source_file_path   = optional(string, "/var/www")
    allowed_principals = optional(list(string), ["*"])
  })
  default = {
    bucket_name          = "s3-static-site"
    bucket_acl           = "private"
    bucket_suffix        = ""
    enable_force_destroy = false
    object_ownership     = "BucketOwnerPreferred"
    enable_versioning    = false
    index_document       = "index.html"
    error_document       = ""
    public_access = {
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
    }
    source_file_path   = "/var/www"
    allowed_principals = ["*"]
  }

  validation {
    condition     = can(regex("^[a-z0-9-]{3,47}$", var.s3_config.bucket_name)) && (length(var.s3_config.bucket_name) + length(var.s3_config.bucket_suffix) <= 63)
    error_message = "The bucket name must be DNS-compliant: lowercase letters, numbers, and hyphens only, and its combined length with the suffix must not exceed 63 characters."
  }

  validation {
    condition     = contains(["private", "public-read"], var.s3_config.bucket_acl)
    error_message = "The bucket ACL must be either 'private' or 'public-read'."
  }

  validation {
    condition     = length(var.s3_config.bucket_suffix) <= 16
    error_message = "The bucket suffix must be 16 characters or fewer."
  }

  validation {
    condition     = contains(["BucketOwnerPreferred", "ObjectWriter", "BucketOwnerEnforced"], var.s3_config.object_ownership)
    error_message = "The object ownership setting must be one of 'BucketOwnerPreferred', 'ObjectWriter', or 'BucketOwnerEnforced'."
  }

  validation {
    condition     = length(var.s3_config.index_document) > 0
    error_message = "The index document name cannot be empty."
  }

  validation {
    condition     = length(var.s3_config.source_file_path) > 0
    error_message = "The source file path cannot be empty."
  }

  validation {
    condition     = length(var.s3_config.allowed_principals) > 0
    error_message = "At least one allowed principal must be specified."
  }
}

variable "cdn_config" {
  description = "Settings for enabling HTTPS, CloudFront, ACM, and optional custom domain configurations."
  type = object({
    enable = bool
    domain = object({
      name     = string
      sub_name = string
      ttl      = optional(number, 300)
    })
    validation_method      = optional(string, "DNS")
    origin_access_comment  = optional(string, "Access Identity for S3 Origin")
    allowed_methods        = optional(list(string), ["GET", "HEAD", "OPTIONS"])
    cached_methods         = optional(list(string), ["GET", "HEAD"])
    enable_compression     = optional(bool, true)
    protocol_policy        = optional(string, "redirect-to-https")
    forward_query_string   = optional(bool, false)
    forward_cookies        = optional(string, "none")
    minimum_ttl            = optional(number, 0)
    default_ttl            = optional(number, 300)
    maximum_ttl            = optional(number, 1200)
    price_class            = optional(string, "PriceClass_All")
    error_page_path        = optional(string, "/error.html")
    error_page_cache_ttl   = optional(number, 300)
    ssl_support_method     = optional(string, "sni-only")
    minimum_tls_version    = optional(string, "TLSv1.2_2021")
    geo_restriction_policy = optional(string, "none")
  })

  default = {
    enable = false
    domain = {
      name     = ""
      sub_name = ""
      ttl      = 300
    }
    validation_method      = "DNS"
    origin_access_comment  = "Access Identity for S3 Origin"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
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

  validation {
    condition = (!var.cdn_config.enable ||
      (var.cdn_config.domain.name != "" &&
    can(regex("^[a-zA-Z0-9.-]+$", var.cdn_config.domain.name))))
    error_message = "If enable is true, name must be a valid DNS-compliant domain name."
  }

  validation {
    condition = (!var.cdn_config.enable ||
      (var.cdn_config.domain.sub_name != "" &&
    can(regex("^[a-zA-Z0-9.-]+$", var.cdn_config.domain.sub_name))))
    error_message = "If enable is true, sub_name must be a valid DNS-compliant subdomain name."
  }

  validation {
    condition     = contains(["allow-all", "redirect-to-https", "https-only"], var.cdn_config.protocol_policy)
    error_message = "protocol_policy must be one of: allow-all, redirect-to-https, https-only."
  }

  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.cdn_config.price_class)
    error_message = "price_class must be one of: PriceClass_All, PriceClass_200, PriceClass_100."
  }

  validation {
    condition     = contains(["sni-only", "vip"], var.cdn_config.ssl_support_method)
    error_message = "ssl_support_method must be one of: sni-only, vip."
  }

  validation {
    condition     = contains(["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2", "TLSv1.2_2018", "TLSv1.2_2021"], var.cdn_config.minimum_tls_version)
    error_message = "minimum_tls_version must be one of: SSLv3, TLSv1, TLSv1.1, TLSv1.2, TLSv1.2_2018, TLSv1.2_2021."
  }

  validation {
    condition     = contains(["none", "whitelist", "blacklist"], var.cdn_config.geo_restriction_policy)
    error_message = "geo_restriction_policy must be one of: none, whitelist, blacklist."
  }

  validation {
    condition     = var.cdn_config.minimum_ttl >= 0
    error_message = "minimum_ttl must be greater than or equal to 0."
  }

  validation {
    condition     = var.cdn_config.default_ttl >= var.cdn_config.minimum_ttl
    error_message = "default_ttl must be greater than or equal to minimum_ttl."
  }

  validation {
    condition     = var.cdn_config.maximum_ttl >= var.cdn_config.default_ttl
    error_message = "maximum_ttl must be greater than or equal to default_ttl."
  }

  validation {
    condition     = length(var.cdn_config.allowed_methods) > 0
    error_message = "allowed_methods must contain at least one HTTP method."
  }

  validation {
    condition     = length(var.cdn_config.cached_methods) > 0
    error_message = "cached_methods must contain at least one HTTP method."
  }
}

variable "logging_config" {
  description = "Configuration for S3 bucket logging."
  type = object({
    enable               = bool
    s3_prefix            = optional(string, "s3/")
    cloudfront_prefix    = optional(string, "cloudfront/")
    log_retention_days   = optional(number, 30)
    enable_encryption    = optional(bool, true)
    encryption_algorithm = optional(string, "AES256")
  })
  default = {
    enable               = false
    s3_prefix            = "s3/"
    cloudfront_prefix    = "cloudfront/"
    log_retention_days   = 90
    enable_encryption    = true
    encryption_algorithm = "AES256"
  }

  validation {
    condition = (
      var.logging_config.enable == false ||
      (var.logging_config.enable == true && length(var.logging_config.s3_prefix) > 0)
    )
    error_message = "If logging is enabled, s3_prefix must be a non-empty string."
  }

  validation {
    condition     = var.logging_config.s3_prefix == "" || can(regex("^[a-zA-Z0-9!_.*/-]+$", var.logging_config.s3_prefix))
    error_message = "The s3_prefix must be a valid string containing only alphanumeric characters, hyphens, underscores, slashes, or dots."
  }

  validation {
    condition     = !var.cdn_config.enable || (var.logging_config.cloudfront_prefix == "" || can(regex("^[a-zA-Z0-9!_.*/-]+$", var.logging_config.cloudfront_prefix)))
    error_message = "The cloudfront_prefix must be a valid string containing only alphanumeric characters, hyphens, underscores, slashes, or dots."
  }
}

variable "tags" {
  description = "A map of tags to assign to the resources. Tags are useful for identifying and managing resources in AWS. If no tags are provided, an empty map will be used."
  type        = map(string)
  default     = {}
}
