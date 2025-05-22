###########################
# S3 Bucket Configuration
###########################

# Create KMS key for S3 encryption
resource "aws_kms_key" "s3_key" {
  description             = "KMS key for ${var.app_name}-${var.environment} S3 encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name        = "${var.app_name}-${var.environment}-s3-key"
    Environment = var.environment
  }
}

# Create S3 bucket for static website hosting
resource "aws_s3_bucket" "frontend" {
  bucket = "${var.app_name}-${var.environment}-frontend"

  tags = {
    Name        = "${var.app_name}-${var.environment}-frontend"
    Environment = var.environment
  }
}

# Enable S3 bucket versioning
resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable KMS encryption for the frontend bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Create a KMS key for the logging bucket
resource "aws_kms_key" "logs_key" {
  description             = "KMS key for ${var.app_name}-${var.environment} S3 logs encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name        = "${var.app_name}-${var.environment}-logs-key"
    Environment = var.environment
  }
}

# Create a logging bucket with encryption and versioning
resource "aws_s3_bucket" "logs" {
  bucket = "${var.app_name}-${var.environment}-frontend-logs"

  tags = {
    Name        = "${var.app_name}-${var.environment}-frontend-logs"
    Environment = var.environment
  }
}

# Enable ACLs for the logs bucket
resource "aws_s3_bucket_ownership_controls" "logs_ownership" {
  bucket = aws_s3_bucket.logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Enable versioning for the logging bucket
resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable KMS encryption for the logging bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Enable access logging for the logs bucket (self-logging)
resource "aws_s3_bucket_logging" "logs_self_logging" {
  bucket        = aws_s3_bucket.logs.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "self-logs/"
}

# Set up ACL for the logs bucket to allow CloudFront to write logs
resource "aws_s3_bucket_acl" "logs_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.logs_ownership]

  bucket = aws_s3_bucket.logs.id
  acl    = "log-delivery-write"
}

# Enable logging for the frontend bucket
resource "aws_s3_bucket_logging" "frontend" {
  bucket        = aws_s3_bucket.frontend.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-logs/"
}

# Block public access for logs bucket
resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Configure the bucket for website hosting
resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html" # SPA fallback for client-side routing
  }
}

# Block public access settings for the bucket
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy to allow CloudFront access
resource "aws_s3_bucket_policy" "frontend" {
  bucket     = aws_s3_bucket.frontend.id
  policy     = data.aws_iam_policy_document.frontend_s3_policy.json
  depends_on = [aws_s3_bucket_public_access_block.frontend]
}

data "aws_iam_policy_document" "frontend_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontend.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.frontend.arn]
    }
  }
}

###########################
# WAF Configuration
###########################

resource "aws_wafv2_web_acl" "frontend" {
  name        = "${var.app_name}-${var.environment}-waf"
  description = "WAF Web ACL for ${var.app_name} frontend"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }


    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }


    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }


  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.app_name}-${var.environment}-waf-metrics"
    sampled_requests_enabled   = true
  }

  tags = {
    Name        = "${var.app_name}-${var.environment}-waf"
    Environment = var.environment
  }
}

###########################
# CloudFront Configuration
###########################

# Origin access control for CloudFront
resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "${var.app_name}-${var.environment}-frontend-oac"
  description                       = "OAC for ${var.app_name} frontend"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront distribution for the frontend
resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100" # Use only North America and Europe edge locations
  comment             = "${var.app_name}-${var.environment}-frontend"

  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.frontend.bucket}"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.frontend.bucket}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  # Route all paths to index.html for SPA client-side routing
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logs.bucket_regional_domain_name
    prefix          = "cloudfront-logs/"
  }

  web_acl_id = aws_wafv2_web_acl.frontend.arn

  # Uncomment if you want to use a custom domain with SSL
  # viewer_certificate {
  #   acm_certificate_arn = var.certificate_arn
  #   ssl_support_method  = "sni-only"
  #   minimum_protocol_version = "TLSv1.2_2021"
  # }

  # Add the custom domain as an alias
  # aliases = [var.domain_name]
}

###########################
# Outputs
###########################

output "s3_bucket_name" {
  value = aws_s3_bucket.frontend.id
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.frontend.id
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.frontend.domain_name
}
