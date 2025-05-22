# KMS key for S3 bucket encryption
resource "aws_kms_key" "s3_key" {
  description             = "KMS key for ${var.app_name}-${var.environment} S3 encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name        = "${var.app_name}-${var.environment}-s3-key"
    Environment = var.environment
  }
}

# KMS key for S3 logs encryption
resource "aws_kms_key" "logs_key" {
  description             = "KMS key for ${var.app_name}-${var.environment} S3 logs encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name        = "${var.app_name}-${var.environment}-logs-key"
    Environment = var.environment
  }
}
