data "aws_region" "current" {}

locals {
  base_bucket_name = var.s3_config.bucket_suffix == "" ? var.s3_config.bucket_name : "${var.s3_config.bucket_name}-${var.s3_config.bucket_suffix}"
  s3_bucket_name   = var.cdn_config.enable ? "${local.base_bucket_name}.${var.cdn_config.domain.name}" : local.base_bucket_name
  sub_domain_name  = "${var.cdn_config.domain.sub_name}.${var.cdn_config.domain.name}"
}

resource "aws_s3_bucket" "this" {
  bucket        = local.s3_bucket_name
  force_destroy = var.s3_config.enable_force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  index_document {
    suffix = var.s3_config.index_document
  }

  dynamic "error_document" {
    for_each = var.s3_config.error_document != "" ? [var.s3_config.error_document] : []
    content {
      key = var.s3_config.error_document
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.s3_config.enable_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = var.s3_config.object_ownership
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.s3_config.public_access.block_public_acls
  block_public_policy     = var.s3_config.public_access.block_public_policy
  ignore_public_acls      = var.s3_config.public_access.ignore_public_acls
  restrict_public_buckets = var.s3_config.public_access.restrict_public_buckets
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = var.s3_config.bucket_acl

  depends_on = [
    aws_s3_bucket_ownership_controls.this,
    aws_s3_bucket_public_access_block.this,
  ]
}

resource "aws_s3_object" "this" {
  for_each = fileset(var.s3_config.source_file_path, "**/*")

  bucket = aws_s3_bucket.this.id
  key    = each.value
  source = "${var.s3_config.source_file_path}/${each.value}"

  # Determine content type dynamically based on file extension
  content_type = lookup(
    {
      ".avi"   = "video/x-msvideo"
      ".css"   = "text/css"
      ".csv"   = "text/csv"
      ".eot"   = "application/vnd.ms-fontobject"
      ".gif"   = "image/gif"
      ".gz"    = "application/gzip"
      ".html"  = "text/html"
      ".jpeg"  = "image/jpeg"
      ".jpg"   = "image/jpeg"
      ".js"    = "application/javascript"
      ".json"  = "application/json"
      ".mp3"   = "audio/mpeg"
      ".mp4"   = "video/mp4"
      ".ogg"   = "audio/ogg"
      ".pdf"   = "application/pdf"
      ".png"   = "image/png"
      ".svg"   = "image/svg+xml"
      ".tar"   = "application/x-tar"
      ".ttf"   = "font/ttf"
      ".txt"   = "text/plain"
      ".wav"   = "audio/wav"
      ".webm"  = "video/webm"
      ".woff"  = "font/woff"
      ".woff2" = "font/woff2"
      ".xml"   = "application/xml"
      ".zip"   = "application/zip"
    },
    regex("\\.[^.]+$", each.value),
    "application/octet-stream"
  )
}

resource "aws_s3_bucket_policy" "this" {
  count = var.s3_config.public_access.block_public_policy == false ? 1 : 0

  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.this.arn}/*"
        Principal = {
          AWS = join(",", var.s3_config.allowed_principals)
        }
      }
    ]
  })

  depends_on = [
    aws_s3_bucket_acl.this
  ]
}

###############
# ROUTE 53

data "aws_route53_zone" "this" {
  count = var.cdn_config.enable ? 1 : 0

  name = var.cdn_config.domain.name
}

resource "aws_route53_record" "ssl_validation" {
  for_each = var.cdn_config.enable ? {
    for opt in aws_acm_certificate.this[0].domain_validation_options
  : opt.domain_name => opt } : {}

  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  zone_id = data.aws_route53_zone.this[0].id
  records = [each.value.resource_record_value]
  ttl     = var.cdn_config.domain.ttl
}

resource "aws_route53_record" "cloudfront" {
  count = var.cdn_config.enable ? 1 : 0

  zone_id = data.aws_route53_zone.this[0].id
  name    = local.sub_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this[0].domain_name
    zone_id                = aws_cloudfront_distribution.this[0].hosted_zone_id
    evaluate_target_health = true
  }
}

###############
# ACM

resource "aws_acm_certificate" "this" {
  count = var.cdn_config.enable ? 1 : 0

  provider                  = aws.us_east_1
  domain_name               = local.sub_domain_name
  subject_alternative_names = [local.sub_domain_name]
  validation_method         = var.cdn_config.validation_method
}

resource "aws_acm_certificate_validation" "this" {
  count = var.cdn_config.enable ? 1 : 0

  provider        = aws.us_east_1
  certificate_arn = aws_acm_certificate.this[0].arn

  validation_record_fqdns = [
    for record in aws_route53_record.ssl_validation : record.fqdn
  ]

  depends_on = [
    aws_route53_record.ssl_validation
  ]
}

###############
# CLOUDFRONT

resource "aws_cloudfront_origin_access_identity" "this" {
  count   = var.cdn_config.enable ? 1 : 0
  comment = var.cdn_config.origin_access_comment
}

resource "aws_cloudfront_distribution" "this" {
  count = var.cdn_config.enable ? 1 : 0

  enabled = var.cdn_config.enable
  aliases = [local.sub_domain_name]

  custom_error_response {
    error_code            = 403
    response_page_path    = var.cdn_config.error_page_path
    response_code         = 403
    error_caching_min_ttl = var.cdn_config.error_page_cache_ttl
  }

  custom_error_response {
    error_code            = 404
    response_page_path    = var.cdn_config.error_page_path
    response_code         = 404
    error_caching_min_ttl = var.cdn_config.error_page_cache_ttl
  }

  default_cache_behavior {
    allowed_methods = var.cdn_config.allowed_methods
    cached_methods  = var.cdn_config.cached_methods
    compress        = var.cdn_config.enable_compression

    forwarded_values {
      query_string = var.cdn_config.forward_query_string
      cookies {
        forward = var.cdn_config.forward_cookies
      }
    }

    min_ttl                = var.cdn_config.minimum_ttl
    default_ttl            = var.cdn_config.default_ttl
    max_ttl                = var.cdn_config.maximum_ttl
    target_origin_id       = "origin-${aws_s3_bucket.this.id}"
    viewer_protocol_policy = var.cdn_config.protocol_policy
  }

  default_root_object = var.s3_config.index_document

  dynamic "logging_config" {
    for_each = var.logging_config.enable ? [1] : []
    content {
      bucket = aws_s3_bucket.logging[0].bucket_domain_name
      prefix = var.logging_config.cloudfront_prefix
    }
  }

  origin {
    origin_id   = "origin-${aws_s3_bucket.this.id}"
    domain_name = aws_s3_bucket.this.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this[0].cloudfront_access_identity_path
    }
  }

  price_class = var.cdn_config.price_class

  restrictions {
    geo_restriction {
      restriction_type = var.cdn_config.geo_restriction_policy
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.this[0].arn
    ssl_support_method       = var.cdn_config.ssl_support_method
    minimum_protocol_version = var.cdn_config.minimum_tls_version
  }

  tags = var.tags
}

###############
# LOGGING

resource "aws_s3_bucket" "logging" {
  count = var.logging_config.enable ? 1 : 0

  bucket        = "${local.s3_bucket_name}-logs"
  force_destroy = var.s3_config.enable_force_destroy

  tags = merge(var.tags, { Name = "${local.s3_bucket_name}-logs" })
}

resource "aws_s3_bucket_ownership_controls" "logging" {
  count = var.logging_config.enable ? 1 : 0

  bucket = aws_s3_bucket.logging[0].id

  rule {
    object_ownership = var.s3_config.object_ownership
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logging" {
  count = var.logging_config.enable && var.logging_config.enable_encryption ? 1 : 0

  bucket = aws_s3_bucket.logging[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.logging_config.encryption_algorithm
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logging" {
  count = var.logging_config.enable ? 1 : 0

  bucket = aws_s3_bucket.logging[0].id

  rule {
    id     = "log-retention"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = var.logging_config.log_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.logging_config.log_retention_days
    }
  }
}

resource "aws_s3_bucket_logging" "logging" {
  count = var.logging_config.enable ? 1 : 0

  bucket        = aws_s3_bucket.this.id
  target_bucket = aws_s3_bucket.logging[0].id
  target_prefix = var.logging_config.s3_prefix

  depends_on = [
    aws_s3_bucket.logging
  ]
}
