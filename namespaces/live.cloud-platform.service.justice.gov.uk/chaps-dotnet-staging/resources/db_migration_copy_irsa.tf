#This role is for a temporary Kubernetes pod/job that copies ModPlatform S3/KMS → CloudPlatform S3/KMS

locals {
  mp_db_migration_bucket_name     = "cdpt-chaps-staging-db-migration-631213771998"
  mp_db_migration_bucket_arn      = "arn:aws:s3:::cdpt-chaps-staging-db-migration-631213771998"
  mp_db_migration_kms_key_arn     = "arn:aws:kms:eu-west-2:631213771998:key/b953332c-1677-4da9-a4db-44f0bccba42d"
}

module "db_migration_copy_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "chaps-db-migration-copy"

  role_policy_arns = {
    db_migration_copy = aws_iam_policy.db_migration_copy.arn
  }

  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  team_name              = var.team_name
}


data "aws_iam_policy_document" "db_migration_copy" {
  statement {
    sid = "ListMpMigrationBucket"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]

    resources = [
      local.mp_db_migration_bucket_arn
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = [
        local.db_migration_prefix,
        "${local.db_migration_prefix}/",
        "${local.db_migration_prefix}/*"

      ]
    }
  }

  statement {
    sid = "ReadMpMigrationBackupObjects"

    actions = [
      "s3:GetObject",
      "s3:GetObjectAttributes"
    ]

    resources = [
      "${local.mp_db_migration_bucket_arn}/${local.db_migration_prefix}/*"
    ]
  }

  statement {
    sid = "DecryptMpMigrationBackupObjects"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]

    resources = [
      local.mp_db_migration_kms_key_arn
    ]
  }

  statement {
    sid = "ListCpMigrationBucket"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.db_migration.arn
    ]

    condition {
      test      = "StringLike"
      variable  = "s3:prefix"
      values    = [
        local.db_migration_prefix,
        "${local.db_migration_prefix}/",
        "${local.db_migration_prefix}/*"

      ]
    }
  }

  statement {
    sid = "WriteCpMigrationBackupObjects"

    actions = [
      "s3:GetObject",
      "s3:GetObjectAttributes",
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts"
    ]

    resources = [
      local.db_migration_objects_prefix_arn
    ]
  }

  statement {
    sid = "EncryptCpMigrationBackupObjects"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]

    resources = [
      aws_kms_key.db_migration.arn
    ]
  }
}

resource "aws_iam_policy" "db_migration_copy" {
  name   = "${var.namespace}-db-migration-copy"
  policy = data.aws_iam_policy_document.db_migration_copy.json

  tags = local.db_migration_tags
}

output "db_migration_copy_irsa_role_arn" {
  value       = module.db_migration_copy_irsa.role_arn
  description = "IRSA role ARN that MP must allow to read/decrypt the migration backup"
}

output "db_migration_copy_irsa_role_name" {
  value       = module.db_migration_copy_irsa.role_name
  description = "IRSA role name used by the CHAPS DB migration copy service account"
}

output "db_migration_copy_service_account_name" {
  value       = module.db_migration_copy_irsa.service_account.name
  description = "Kubernetes service account used to copy CHAPS DB backups from MP S3 to CP S3"
}
