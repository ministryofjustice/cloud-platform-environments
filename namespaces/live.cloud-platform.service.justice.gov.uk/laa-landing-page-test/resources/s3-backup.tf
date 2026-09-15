/*
 * DB-2 (docs/backup-and-recovery-strategy.md) — test's own pg_dump backup bucket and
 * restore role. No writer yet (only dev's pg_dump CronJob has been built so far).
 *
 * Redesigned 2026-09-14: one bucket per environment (dev, test, prd), each entirely
 * self-contained in its own namespace's Terraform state — no cross-namespace
 * hardcoded bucket ARN. The only asymmetry: prd's bucket will, in future, also host
 * the GH-2 GitHub mirror backup under a separate github-mirror/ prefix (there's only
 * one GitHub repo, so that doesn't need a copy per environment) — this test bucket
 * only ever holds pg-dump/.
 *
 * Object Lock: GOVERNANCE mode, not COMPLIANCE — same reasoning as prd/dev (see
 * prd's s3-backup.tf): the dev-test rehearsal never actually exercised a read, so
 * the irrevocable mode is deferred until that's been proven out.
 *
 * Restore role is unattached (see prd's s3-backup.tf for the IRSA pod-assumable
 * caveat) — kept here rather than shared with prd/dev because a restore pod runs in
 * whichever namespace holds the RDS instance being restored into.
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

# k8s Secret a future deploy_test.yml / pg_dump writer can read BACKUP_BUCKET_NAME
# from, mirroring dev's backup-bucket-output (see dev's s3-backup.tf) — not wired
# into any workflow yet since test has no writer role built.
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
  description = "Read-only (list + get) access to this bucket's pg-dump/ prefix, for a pod run during a test-namespace DB restore rehearsal. Not attached to any standing workload. No write/delete."
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
