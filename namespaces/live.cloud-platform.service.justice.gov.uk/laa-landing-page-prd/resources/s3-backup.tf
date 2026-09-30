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
      mode = "GOVERNANCE"
      days = 365
    }
  }
}

# --- Write-only: weekly pg_dump CronJob (DB-2) -----------------------------

data "aws_iam_policy_document" "pg_dump_backup_write" {
  statement {
    sid    = "PutPgDumpObjects"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:AbortMultipartUpload",
    ]
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
  description = "Write-only access for the weekly pg_dump CronJob, scoped to this bucket's pg-dump/ prefix (kept separate from github-mirror/, this bucket's other stream). No get/list/delete."
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
  description = "Read-only (list + get) access to the pg-dump/ prefix, for a pod run during a DB restore. Not attached to any standing workload. No write/delete."
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

# --- Read-only: GitHub mirror restore, unattached until an incident pod needs it -
# Separate from restore_pg_dump above

data "aws_iam_policy_document" "restore_github_mirror" {
  statement {
    sid       = "ListGithubMirrorPrefix"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [module.backup.bucket_arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["github-mirror/*"]
    }
  }

  statement {
    sid       = "GetGithubMirrorObjects"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${module.backup.bucket_arn}/github-mirror/*"]
  }
}

resource "aws_iam_policy" "restore_github_mirror" {
  name        = "${var.namespace}-restore-github-mirror-policy"
  description = "Read-only (list + get) access to the github-mirror/ prefix, for a pod run during a GitHub restore. Not attached to any standing workload. No write/delete."
  policy      = data.aws_iam_policy_document.restore_github_mirror.json
}

module "irsa_restore_github_mirror" {
  source                = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name      = var.eks_cluster_name
  service_account_name  = "irsa-laa-landing-page-${var.environment}-restore-github-mirror"
  namespace             = var.namespace

  role_policy_arns = {
    restore_github_mirror = aws_iam_policy.restore_github_mirror.arn
  }
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name               = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

# --- Write-only: GitHub Actions OIDC role for the mirror-backup workflow ---
# Not IRSA (Actions has no pod identity). Ref-scoped trust + repo-level
# secrets/variables since the workflow runs with no `environment:` set.

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "github_mirror_write_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:ministryofjustice/laa-landing-page:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "github_mirror_write" {
  name               = "${var.namespace}-github-mirror-write"
  assume_role_policy = data.aws_iam_policy_document.github_mirror_write_assume.json

  tags = {
    namespace               = var.namespace
    business-unit           = var.business_unit
    application             = var.application
    is-production           = var.is_production
    environment-name        = var.environment
    owner                   = var.team_name
    infrastructure-support  = var.infrastructure_support
  }
}

data "aws_iam_policy_document" "github_mirror_write" {
  statement {
    sid    = "PutGithubMirrorObjects"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:AbortMultipartUpload",
    ]
    resources = ["${module.backup.bucket_arn}/github-mirror/*"]
  }

  statement {
    sid       = "ListMultipartUploadsForGithubMirrorPrefix"
    effect    = "Allow"
    actions   = ["s3:ListBucketMultipartUploads"]
    resources = [module.backup.bucket_arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["github-mirror/*"]
    }
  }
}

resource "aws_iam_policy" "github_mirror_write" {
  name        = "${var.namespace}-github-mirror-write-policy"
  description = "Write-only access for the GitHub mirror-backup workflow, scoped to this bucket's github-mirror/ prefix (kept separate from pg-dump/, this bucket's other stream). No get/list/delete."
  policy      = data.aws_iam_policy_document.github_mirror_write.json
}

resource "aws_iam_role_policy_attachment" "github_mirror_write" {
  role       = aws_iam_role.github_mirror_write.name
  policy_arn = aws_iam_policy.github_mirror_write.arn
}

# Repo-level, not Environment-scoped — no `environment:` on this job.
resource "github_actions_secret" "github_mirror_role_to_assume" {
  repository      = "laa-landing-page"
  secret_name     = "BACKUP_S3_ROLE_TO_ASSUME"
  plaintext_value = aws_iam_role.github_mirror_write.arn
}

resource "github_actions_variable" "backup_bucket_name" {
  repository    = "laa-landing-page"
  variable_name = "BACKUP_S3_BUCKET_NAME"
  value         = module.backup.bucket_name
}

resource "github_actions_variable" "backup_s3_region" {
  repository    = "laa-landing-page"
  variable_name = "BACKUP_S3_REGION"
  value         = "eu-west-2"
}
