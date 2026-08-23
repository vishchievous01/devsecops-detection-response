terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

#
# KMS key for S3 encryption
#
resource "aws_kms_key" "devsecops_s3" {
  description             = "KMS key for DevSecOps demo S3 encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "EnableRootPermissions"
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }

        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = {
    Project = "devsecops-detection-response"
  }
}

#
# Current AWS account
#
data "aws_caller_identity" "current" {}

#
# KMS alias
#
resource "aws_kms_alias" "devsecops_s3" {
  name          = "alias/devsecops-s3"
  target_key_id = aws_kms_key.devsecops_s3.key_id
}

#
# Main application S3 bucket
#
resource "aws_s3_bucket" "devsecops_demo" {
  bucket = "devsecops-demo-security-test"

  tags = {
    Project = "devsecops-detection-response"
  }
}

#
# Block all public access
#
resource "aws_s3_bucket_public_access_block" "devsecops_demo" {
  bucket = aws_s3_bucket.devsecops_demo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#
# Enable versioning
#
resource "aws_s3_bucket_versioning" "devsecops_demo" {
  bucket = aws_s3_bucket.devsecops_demo.id

  versioning_configuration {
    status = "Enabled"
  }
}

#
# KMS encryption
#
resource "aws_s3_bucket_server_side_encryption_configuration" "devsecops_demo" {
  bucket = aws_s3_bucket.devsecops_demo.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.devsecops_s3.arn
      sse_algorithm     = "aws:kms"
    }

    bucket_key_enabled = true
  }
}

#
# Dedicated S3 access-log bucket
#
resource "aws_s3_bucket" "devsecops_logs" {
  bucket = "devsecops-demo-security-logs"

  tags = {
    Project = "devsecops-detection-response"
    Purpose = "s3-access-logs"
  }
}

#
# Block public access to log bucket
#
resource "aws_s3_bucket_public_access_block" "devsecops_logs" {
  bucket = aws_s3_bucket.devsecops_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#
# Version logging bucket
#
resource "aws_s3_bucket_versioning" "devsecops_logs" {
  bucket = aws_s3_bucket.devsecops_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

#
# KMS encryption for logging bucket
#
resource "aws_s3_bucket_server_side_encryption_configuration" "devsecops_logs" {
  bucket = aws_s3_bucket.devsecops_logs.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.devsecops_s3.arn
      sse_algorithm     = "aws:kms"
    }

    bucket_key_enabled = true
  }
}

#
# Lifecycle policy for logging bucket
#
resource "aws_s3_bucket_lifecycle_configuration" "devsecops_logs" {
  bucket = aws_s3_bucket.devsecops_logs.id

  rule {
    id     = "log-retention"
    status = "Enabled"

    filter {
      prefix = ""
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    expiration {
      days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

#
# Enable S3 access logging
#
resource "aws_s3_bucket_logging" "devsecops_demo" {
  bucket = aws_s3_bucket.devsecops_demo.id

  target_bucket = aws_s3_bucket.devsecops_logs.id
  target_prefix = "devsecops-demo/"
}

#
# Lifecycle policy for application bucket
#
resource "aws_s3_bucket_lifecycle_configuration" "devsecops_demo" {
  bucket = aws_s3_bucket.devsecops_demo.id

  rule {
    id     = "secure-data-lifecycle"
    status = "Enabled"

    filter {
      prefix = ""
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
