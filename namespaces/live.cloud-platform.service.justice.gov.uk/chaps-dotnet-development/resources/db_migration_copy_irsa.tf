#This role is for a temporary Kubernetes pod/job that copies ModPlatform S3/KMS → CloudPlatform S3/KMS

locals {
  mp_db_migration_bucket_name     = "cdpt-chaps-dev-db-migration-513884314856"
  mp_db_migration_bucket_arn      = "arn:aws:s3:::cdpt-chaps-dev-db-migration-513884314856"
  mp_db_migration_kms_key_arn     = "arn:aws:kms:eu-west-2:513884314856:key/bb997c65-4301-4f74-8640-b9918e8c9c2f"
}

module "db_migration_copy_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "chaps-db-migration-copy"

  role_policy_arns = [
    aws_iam_policy.db_migration_copy.arn
  ]
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

output "db_migration_copy_service_account_name" {
  value       = "chaps-db-migration-copy"
  description = "Kubernetes service account used to copy CHAPS DB backups from MP S3 to CP S3"
}

output "db_migration_copy_policy_arn" {
  value       = aws_iam_policy.db_migration_copy.arn
  description = "IAM policy ARN for CHAPS DB migration copy role"
}

output "db_migration_copy_irsa_role_arn" {
  value       = module.db_migration_copy_irsa.aws_iam_role_arn
  description = "IRSA role ARN that MP must allow to read/decrypt the migration backup"
}
