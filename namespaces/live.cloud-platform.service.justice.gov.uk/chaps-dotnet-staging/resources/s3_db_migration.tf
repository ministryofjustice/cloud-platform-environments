locals {
  db_migration_environment_short_name = "staging"
  db_migration_prefix = "native-backups/${local.db_migration_environment_short_name}"
  db_migration_bucket_name = "chaps-${local.db_migration_environment_short_name}-db-migration-${data.aws_caller_identity.current.account_id}"

  db_migration_tags = {
    application            = var.application
    business_unit          = var.business_unit
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
    is_production          = var.is_production
    namespace              = var.namespace
    team_name              = var.team_name
  }
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "db_migration" {
  description             = "CHAPS ${var.environment} database migration s3 bucket"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(local.db_migration_tags, {
    Name    = "${var.namespace}-db-migration"
    Purpose = "CHAPS database migration restore"
  })
}

resource "aws_kms_alias" "db_migration" {
  name          = "alias/${var.namespace}-db-migration"
  target_key_id = aws_kms_key.db_migration.key_id
}

resource "aws_s3_bucket" "db_migration" {
  bucket     = local.db_migration_bucket_name

  tags = merge(local.db_migration_tags, {
    Name     = local.db_migration_bucket_name
    Purpose  = "CHAPS database migration restore"
  })
}

resource "aws_s3_bucket_public_access_block" "db_migration" {
  bucket = aws_s3_bucket.db_migration.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "db_migration" {
  bucket = aws_s3_bucket.db_migration.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "db_migration" {
  bucket = aws_s3_bucket.db_migration.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "db_migration" {
  bucket = aws_s3_bucket.db_migration.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.db_migration.arn
    }

    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "db_migration" {
  bucket = aws_s3_bucket.db_migration.id

  depends_on = [
    aws_s3_bucket_versioning.db_migration,
    aws_s3_bucket_server_side_encryption_configuration.db_migration
  ]

  rule {
    id     = "expire-db-migration-backups"
    status = "Enabled"

    filter {
      prefix = "${local.db_migration_prefix}/"
    }

    expiration {
      days = 14
    }

    noncurrent_version_expiration {
      noncurrent_days = 14
    }
  }
}

data "aws_iam_policy_document" "db_migration_bucket_policy" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.db_migration.arn,
      "${aws_s3_bucket.db_migration.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "db_migration" {
  bucket = aws_s3_bucket.db_migration.id
  policy = data.aws_iam_policy_document.db_migration_bucket_policy.json
}


output "db_migration_bucket_name" {
  value       = aws_s3_bucket.db_migration.bucket
  description = "CP S3 bucket for CHAPS database migration backups"
}

output "db_migration_bucket_arn" {
  value       = aws_s3_bucket.db_migration.arn
  description = "CP S3 bucket ARN for CHAPS database migration backups"
}

output "db_migration_kms_key_arn" {
  value       = aws_kms_key.db_migration.arn
  description = "CP KMS key ARN for CHAPS database migration backups"
}

output "db_migration_prefix" {
  value       = local.db_migration_prefix
  description = "S3 prefix for CHAPS database migration backups"
}
