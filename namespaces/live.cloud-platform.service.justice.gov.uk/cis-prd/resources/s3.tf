
# -----------------------------------------------------------------------------
# S3 Bucket for Static Website Hosting (regional)
# -----------------------------------------------------------------------------
# checkov:skip=CKV_AWS_145:KMS encryption not required - using AES256 server-side encryption
# checkov:skip=CKV_AWS_18:Access logging not required - CloudFront provides access logs
# checkov:skip=CKV2_AWS_62:Event notifications not required for static website bucket
# checkov:skip=CKV2_AWS_61:Lifecycle configuration not required - versioning handles retention
# checkov:skip=CKV_AWS_144:Cross-region replication not required for non-production environments
resource "aws_s3_bucket" "frontend" {
  bucket = var.s3_bucket_name

  tags = merge(var.tags, {
    Name = var.s3_bucket_name
  })
}

resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------------------------
# S3 Bucket Policy for CloudFront Access
# -----------------------------------------------------------------------------
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.frontend.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.frontend.arn
          }
        }
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# S3 Bucket for CloudFront Access Logs
# -----------------------------------------------------------------------------
# checkov:skip=CKV_AWS_145:KMS encryption not required - using AES256 server-side encryption for logs
# checkov:skip=CKV_AWS_18:Access logging not required for CloudFront logs bucket
# checkov:skip=CKV2_AWS_62:Event notifications not required for CloudFront logs bucket
# checkov:skip=CKV_AWS_144:Cross-region replication not required for log buckets
resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "${var.s3_bucket_name}-cloudfront-logs"

  tags = merge(var.tags, {
    Name = "${var.s3_bucket_name}-cloudfront-logs"
  })
}

resource "aws_s3_bucket_versioning" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudFront requires ACLs to be enabled for log delivery
# checkov:skip=CKV2_AWS_65:ACLs required for CloudFront log delivery - ownership controls configured
resource "aws_s3_bucket_ownership_controls" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  acl    = "log-delivery-write"

  depends_on = [
    aws_s3_bucket_ownership_controls.cloudfront_logs,
    aws_s3_bucket_public_access_block.cloudfront_logs,
  ]
}

resource "aws_s3_bucket_policy" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontLogDelivery"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudfront_logs.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.frontend.arn
          }
        }
      },
      {
        Sid    = "AllowCloudFrontLogDeliveryAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudfront_logs.arn
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.frontend.arn
          }
        }
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.cloudfront_logs]
}

resource "kubernetes_secret" "s3_bucket_output" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = aws_s3_bucket.frontend.arn
    bucket_name = aws_s3_bucket.frontend.id
  }
}

# Lifecycle policy to expire old logs (30 days by default)
resource "aws_s3_bucket_lifecycle_configuration" "cloudfront_logs" {
  #checkov:skip=CKV_AWS_300:CloudFront log delivery does not use multipart uploads
  bucket = aws_s3_bucket.cloudfront_logs.id

  rule {
    id     = "expire-old-logs"
    status = "Enabled"

    filter {
      prefix = "" # Apply to all objects
    }

    expiration {
      days = var.cloudfront_log_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }
}
