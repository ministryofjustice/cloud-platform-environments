module "backup" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"

  bucket_name = "laa-landing-page-backup-${var.environment}"
  versioning  = true

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name               = var.team_name
  namespace               = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  lifecycle_rule = [
    {
      id      = "expire-370d"
      enabled = true
      expiration = [
        { days = 370 }, # Slightly beyond the 365-day Object Lock retention below
      ]
      noncurrent_version_expiration = [
        { days = 370 },
      ]
      abort_incomplete_multipart_upload_days = 7
    },
  ]
}

resource "aws_s3_bucket_object_lock_configuration" "backup" {
  bucket = module.backup.bucket_name

  rule {
    default_retention {
      mode = "GOVERNANCE" # See header comment — do not switch to COMPLIANCE yet
      days = 365
    }
  }
}

# --- Write-only: dev's weekly pg_dump CronJob -------------------------------

data "aws_iam_policy_document" "pg_dump_backup_write" {
  statement {
    sid       = "PutPgDumpObjects"
    effect    = "Allow"
    actions   = ["s3:PutObject", "s3:AbortMultipartUpload"]
    resources = ["${module.backup.bucket_arn}/pg-dump/*"]
  }

  statement {
    sid       = "ListMultipartUploadsForPgDumpPrefix"
    effect    = "Allow"
    actions   = ["s3:ListBucketMultipartUploads"]
    resources = [module.backup.bucket_arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["pg-dump/*"]
    }
  }
}

resource "aws_iam_policy" "pg_dump_backup_write" {
  name        = "${var.namespace}-pg-dump-backup-write-policy"
  description = "Write-only access for the dev namespace's weekly pg_dump CronJob, scoped to this bucket's pg-dump/ prefix. No get/list/delete."
  policy      = data.aws_iam_policy_document.pg_dump_backup_write.json
}

module "irsa_pg_dump_backup" {
  source                = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name      = var.eks_cluster_name
  service_account_name  = "irsa-laa-landing-page-${var.environment}-pg-dump-backup"
  namespace             = var.namespace

  role_policy_arns = {
    pg_dump_backup_write = aws_iam_policy.pg_dump_backup_write.arn
  }
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name               = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "backup_bucket" {
  metadata {
    name      = "backup-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.backup.bucket_arn
    bucket_name = module.backup.bucket_name
  }
}

# --- Read-only: pg_dump restore, unattached until an incident pod needs it -

data "aws_iam_policy_document" "restore_pg_dump" {
  statement {
    sid       = "ListPgDumpPrefix"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [module.backup.bucket_arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["pg-dump/*"]
    }
  }

  statement {
    sid       = "GetPgDumpObjects"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${module.backup.bucket_arn}/pg-dump/*"]
  }
}

resource "aws_iam_policy" "restore_pg_dump" {
  name        = "${var.namespace}-restore-pg-dump-policy"
  description = "Read-only (list + get) access to this bucket's pg-dump/ prefix, for a pod run during a dev-namespace DB restore rehearsal. Not attached to any standing workload. No write/delete."
  policy      = data.aws_iam_policy_document.restore_pg_dump.json
}

module "irsa_restore_pg_dump" {
  source                = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name      = var.eks_cluster_name
  service_account_name  = "irsa-laa-landing-page-${var.environment}-restore-pg-dump"
  namespace             = var.namespace

  role_policy_arns = {
    restore_pg_dump = aws_iam_policy.restore_pg_dump.arn
  }
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name               = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
