data "aws_caller_identity" "rds_backups" {}
data "aws_partition" "rds_backups" {}
data "aws_region" "rds_backups" {}

# The module's generated KMS alias is not necessarily the configured DB name.
data "aws_db_instance" "rds_backup_source" {
  db_instance_identifier = module.rds.db_identifier
}

locals {
  rds_backup_arn_prefix = "arn:${data.aws_partition.rds_backups.partition}:rds:${data.aws_region.rds_backups.name}:${data.aws_caller_identity.rds_backups.account_id}"
  rds_backup_db_arn     = "${local.rds_backup_arn_prefix}:db:${module.rds.db_identifier}"

  # Match the automated timestamp suffix, not the separate "-prod-metabase" DB.
  rds_backup_automated_arn = "${local.rds_backup_arn_prefix}:snapshot:rds:${module.rds.db_identifier}-????-??-??-??-??"

  rds_backup_owner_tags = {
    service     = "laa-info-and-advice-datastore"
    env         = "prod"
    backup-type = "scheduled"
    managed-by  = "datastore-backup-automation"
  }

  rds_backup_tiers = {
    hourly = {
      action          = "rds:CreateDBSnapshot"
      source_arn      = local.rds_backup_db_arn
      snapshot_prefix = "${module.rds.db_identifier}-scheduled-hourly-"
      retention_hours = "24"
    }
    daily = {
      action          = "rds:CopyDBSnapshot"
      source_arn      = local.rds_backup_automated_arn
      snapshot_prefix = "${module.rds.db_identifier}-scheduled-daily-"
      retention_hours = "168"
    }
  }

  rds_backup_snapshot_arns = [
    for tier in local.rds_backup_tiers :
    "${local.rds_backup_arn_prefix}:snapshot:${tier.snapshot_prefix}*"
  ]
}

data "aws_iam_policy_document" "rds_backups" {
  statement {
    sid       = "DescribeSourceDatabase"
    actions   = ["rds:DescribeDBInstances"]
    resources = [local.rds_backup_db_arn]
  }

  statement {
    sid     = "DescribeSnapshotsAndReadTags"
    actions = ["rds:DescribeDBSnapshots", "rds:ListTagsForResource"]
    resources = concat(
      [local.rds_backup_db_arn, local.rds_backup_automated_arn],
      local.rds_backup_snapshot_arns
    )
  }

  # CopyDBSnapshot cannot distinguish source from destination within this scope.
  # The script must reject manual sources, including our existing daily copies.
  dynamic "statement" {
    for_each = local.rds_backup_tiers

    content {
      sid     = "${title(statement.key)}Backup"
      actions = [statement.value.action]
      resources = [
        statement.value.source_arn,
        "${local.rds_backup_arn_prefix}:snapshot:${statement.value.snapshot_prefix}*"
      ]

      dynamic "condition" {
        for_each = merge(local.rds_backup_owner_tags, {
          backup-tier     = statement.key
          retention-hours = statement.value.retention_hours
        })

        content {
          test     = "StringEquals"
          variable = "aws:RequestTag/${condition.key}"
          values   = [condition.value]
        }
      }

      dynamic "condition" {
        for_each = concat(
          ["recovery-point-time", "expires-at"],
          statement.key == "daily" ? ["source-snapshot"] : []
        )

        content {
          test     = "Null"
          variable = "aws:RequestTag/${condition.value}"
          values   = ["false"]
        }
      }
    }
  }

  dynamic "statement" {
    for_each = local.rds_backup_tiers

    content {
      sid       = "Tag${title(statement.key)}Backup"
      actions   = ["rds:AddTagsToResource"]
      resources = ["${local.rds_backup_arn_prefix}:snapshot:${statement.value.snapshot_prefix}*"]

      dynamic "condition" {
        for_each = merge(local.rds_backup_owner_tags, {
          backup-tier     = statement.key
          retention-hours = statement.value.retention_hours
        })

        content {
          test     = "StringEquals"
          variable = "aws:RequestTag/${condition.key}"
          values   = [condition.value]
        }
      }

      dynamic "condition" {
        for_each = concat(
          ["recovery-point-time", "expires-at"],
          statement.key == "daily" ? ["source-snapshot"] : []
        )

        content {
          test     = "Null"
          variable = "aws:RequestTag/${condition.value}"
          values   = ["false"]
        }
      }
    }
  }

  dynamic "statement" {
    for_each = local.rds_backup_tiers

    content {
      sid       = "Delete${title(statement.key)}Backup"
      actions   = ["rds:DeleteDBSnapshot"]
      resources = ["${local.rds_backup_arn_prefix}:snapshot:${statement.value.snapshot_prefix}*"]

      dynamic "condition" {
        for_each = merge(local.rds_backup_owner_tags, {
          backup-tier     = statement.key
          retention-hours = statement.value.retention_hours
        })

        content {
          test     = "StringEquals"
          variable = "aws:ResourceTag/${condition.key}"
          values   = [condition.value]
        }
      }

      dynamic "condition" {
        for_each = concat(
          ["recovery-point-time", "expires-at"],
          statement.key == "daily" ? ["source-snapshot"] : []
        )

        content {
          test     = "Null"
          variable = "aws:ResourceTag/${condition.value}"
          values   = ["false"]
        }
      }
    }
  }

  statement {
    sid       = "DescribeSourceEncryptionKey"
    actions   = ["kms:DescribeKey"]
    resources = [data.aws_db_instance.rds_backup_source.kms_key_id]
  }

  statement {
    sid       = "AllowRdsEncryptionGrant"
    actions   = ["kms:CreateGrant"]
    resources = [data.aws_db_instance.rds_backup_source.kms_key_id]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["rds.${data.aws_region.rds_backups.name}.${data.aws_partition.rds_backups.dns_suffix}"]
    }

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

resource "aws_iam_policy" "rds_backups" {
  name        = "${var.namespace}-rds-backups"
  description = "Scheduled snapshots of the production datastore database only"
  policy      = data.aws_iam_policy_document.rds_backups.json

  tags = {
    application            = var.application
    business-unit          = var.business_unit
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
    is-production          = var.is_production
    namespace              = var.namespace
    owner                  = var.team_name
  }
}

module "rds_backup_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "ia-datastore-prod-backups"
  namespace            = var.namespace

  role_policy_arns = {
    backups = aws_iam_policy.rds_backups.arn
  }

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

output "rds_backup_configuration" {
  description = "Dedicated backup identity and snapshot naming contract; does not enable jobs"
  value = {
    service_account_name   = module.rds_backup_irsa.service_account.name
    role_arn               = module.rds_backup_irsa.role_arn
    db_instance_identifier = module.rds.db_identifier
    kms_key_arn            = data.aws_db_instance.rds_backup_source.kms_key_id
    automated_source_arn   = local.rds_backup_automated_arn
    snapshot_prefixes = {
      for name, tier in local.rds_backup_tiers : name => tier.snapshot_prefix
    }
  }
}
