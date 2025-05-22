# Frontend S3 bucket
resource "aws_s3_bucket" "frontend" {
  bucket = "${var.app_name}-${var.environment}-frontend"

  tags = {
    Name        = "${var.app_name}-${var.environment}-frontend"
    Environment = var.environment
  }
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Logs S3 bucket
resource "aws_s3_bucket" "logs" {
  bucket = "${var.app_name}-${var.environment}-frontend-logs"

  tags = {
    Name        = "${var.app_name}-${var.environment}-frontend-logs"
    Environment = var.environment
  }
}

# Logs bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "logs_ownership" {
  bucket = aws_s3_bucket.logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Logs bucket versioning
resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Logs bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Logs bucket self-logging
resource "aws_s3_bucket_logging" "logs_self_logging" {
  bucket        = aws_s3_bucket.logs.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "self-logs/"
}

# Logs bucket ACL
resource "aws_s3_bucket_acl" "logs_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.logs_ownership]

  bucket = aws_s3_bucket.logs.id
  acl    = "log-delivery-write"
}

# Frontend bucket logging
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

# Website configuration for frontend bucket
resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html" # SPA fallback for client-side routing
  }
}

# Block public access for frontend bucket
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Frontend build and deployment
resource "null_resource" "build_frontend" {
  triggers = {
    api_url = var.api_url
  }

  provisioner "local-exec" {
    command = <<-EOT
      cd /Users/tanvir/src/thoughts/frontend && \
      REACT_APP_API_URL=${var.api_url} npm install && \
      REACT_APP_API_URL=${var.api_url} npm run build && \
      AWS_REGION=${var.aws_region} aws s3 sync build/ s3://${aws_s3_bucket.frontend.id}/ --delete
    EOT
  }

  depends_on = [
    aws_s3_bucket.frontend,
    aws_s3_bucket_website_configuration.frontend,
    aws_s3_bucket_policy.frontend
  ]
}

# Bucket policy for CloudFront access
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
