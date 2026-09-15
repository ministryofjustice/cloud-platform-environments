/*
 * DB-2 / GH-2 (docs/backup-and-recovery-strategy.md, laa-landing-page repo). Prd's
 * own backup bucket, write-only identities, and restore identities.
 *
 * Redesigned 2026-09-14: one bucket per environment (dev, test, prd), each entirely
 * self-contained in its own namespace's Terraform state — dev/test no longer
 * reference this bucket at all. The one asymmetry: this bucket is the only one that
 * also hosts the GH-2 GitHub mirror backup, since there's only one GitHub repo (no
 * per-environment copies needed) — dev's and test's buckets only ever hold pg-dump/.
 * Supersedes the disposable dev-test bucket (laa-landing-page-dev/resources/
 * s3-backup-test.tf), which should be torn down once dev rehearsal is complete
 * rather than reused for prod.
 *
 * Holds two independent backup streams under separate prefixes, each written by its
 * own write-only identity (per the doc's "one identity per purpose" design):
 *   - pg-dump/         — weekly whole-database pg_dump. Consumed by
 *                        deployments/templates/pg-dump-backup-cron.yml.
 *   - github-mirror/   — GitHub repo + metadata mirror (GH-2). Its write-only
 *                        GitHub-OIDC role is not yet built for prd (only the dev-test
 *                        version exists) — added here when that's productionized.
 *
 * No KMS: the s3-bucket module hardcodes SSE-S3 (AES256), not a customer-managed key
 * — there is no kms:Decrypt to grant on the restore roles.
 *
 * Object Lock: GOVERNANCE mode, not COMPLIANCE. The dev-test rehearsal never actually
 * exercised a read (no role there ever had GetObject), so switching to the
 * irrevocable compliance mode is deferred until a restore role has been used to
 * actually pull a dump back down and confirm the mechanics work.
 *
 * Restore access: two separate, standing-but-unattached IRSA roles/ServiceAccounts —
 * deliberately NOT combined into one "restore" identity, even though both are
 * read-only. Reasoning (agreed with the user 2026-09-14): the pg_dump contains
 * personal data / the user_account_status_audit compliance record, while the GitHub
 * mirror is comparatively low-sensitivity repo metadata — a shared credential would
 * blur CloudTrail's audit signal (which restore is this?) and widen blast radius
 * across two different sensitivity classes for no real operational benefit (a DB
 * restore and a GitHub restore are essentially never needed in the same incident).
 * Dev and test each have their own pg_dump restore role against their own bucket
 * (their own s3-backup.tf) — GH-2 restore stays singular, here only, since there's
 * one repo, not one per environment.
 *
 * IMPORTANT — these restore roles are IRSA (EKS-OIDC-trusted ServiceAccounts), NOT
 * the doc's original "human-only, MFA-gated, attached to no workload" break-glass
 * design. IRSA trust is scoped to namespace + ServiceAccount *name*, not to a
 * specific pod instance — so in practice, any pod created in laa-landing-page-prd
 * with the matching serviceAccountName can assume the role. They are unattached
 * today only because no Deployment/Job currently references that SA name; anyone
 * with permission to create a pod in this namespace (including CI, per
 * serviceaccount.tf's broad RBAC grant) could reference it. Treat "unattached" as a
 * lifecycle property, not an access-control guarantee.
 */

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

# k8s Secret deploy_prd.yml can read BACKUP_BUCKET_NAME from, mirroring how
# deploy_dev.yml already reads it from dev's own backup-bucket-output (see dev's
# s3-backup.tf) — not wired into deploy_prd.yml yet.
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
# Separate from restore_pg_dump above — see header comment for why these are not
# combined into one restore identity.

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
