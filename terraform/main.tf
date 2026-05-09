#######################################
# Random Suffix
#######################################

resource "random_id" "suffix" {
  byte_length = 4
}

data "aws_caller_identity" "current" {}

#######################################
# KMS Key for Encryption
#######################################

resource "aws_kms_key" "secure_key" {
  description             = "KMS key for SecureFlow encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

#######################################
# Logging Bucket for S3 Access Logs
#######################################

resource "aws_s3_bucket" "log_bucket" {
  bucket = "secureflow-logs-${random_id.suffix.hex}"

  tags = {
    Name        = "secureflow-log-bucket"
    Environment = "DevSecOps"
  }
}

resource "aws_s3_bucket_public_access_block" "log_block_public" {
  bucket                  = aws_s3_bucket.log_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#######################################
# Secure Main S3 Bucket
#######################################

resource "aws_s3_bucket" "secure_bucket" {
  bucket = "secureflow-${random_id.suffix.hex}"

  tags = {
    Name        = "secureflow-devsecops"
    Environment = "DevSecOps"
  }
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket                  = aws_s3_bucket.secure_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.secure_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.secure_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_logging" "bucket_logging" {
  bucket        = aws_s3_bucket.secure_bucket.id
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "access-logs/"
}

#######################################
# CloudTrail Bucket Policy
#######################################

resource "aws_s3_bucket_policy" "cloudtrail_policy" {
  bucket = aws_s3_bucket.secure_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.secure_bucket.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.secure_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

#######################################
# CloudWatch Log Group for CloudTrail
#######################################

resource "aws_cloudwatch_log_group" "cloudtrail_logs" {
  name              = "/aws/cloudtrail/secureflow"
  retention_in_days = 7
}

#######################################
# IAM Role for CloudTrail → CloudWatch
#######################################

resource "aws_iam_role" "cloudtrail_cloudwatch_role" {
  name = "secureflow-cloudtrail-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "cloudtrail_cloudwatch_policy" {
  name = "secureflow-cloudtrail-policy"
  role = aws_iam_role.cloudtrail_cloudwatch_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "${aws_cloudwatch_log_group.cloudtrail_logs.arn}:*"
    }]
  })
}

#######################################
# Secure CloudTrail
#######################################

resource "aws_cloudtrail" "secure_trail" {
  name                          = "secureflow-trail"
  s3_bucket_name                = aws_s3_bucket.secure_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true

  enable_log_file_validation = true
  kms_key_id                 = aws_kms_key.secure_key.arn

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail_logs.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_cloudwatch_role.arn

  depends_on = [aws_s3_bucket_policy.cloudtrail_policy]
}
