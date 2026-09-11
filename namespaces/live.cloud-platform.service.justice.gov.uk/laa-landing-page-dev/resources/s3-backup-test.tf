module "backup_test" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"

  bucket_name = "laa-landing-page-backup-test-${var.environment}"
  versioning  = true

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name               = var.team_name
  namespace               = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  # Belt-and-braces auto-expiry in case the cleanup pod is never run.
  lifecycle_rule = [
    {
      id      = "expire-test-objects-30d"
      enabled = true
      expiration = [
        { days = 30 },
      ]
      noncurrent_version_expiration = [
        { days = 30 },
      ]
      abort_incomplete_multipart_upload_days = 7
    },
  ]
}

# Retrofits Object Lock onto the module's bucket (versioning is already on via
# `versioning = true` above, which the module wires as the prerequisite).
# GOVERNANCE mode + 1 day so this is genuinely rehearsable and disposable — see
# header comment. Do NOT change mode to COMPLIANCE in this test file.
resource "aws_s3_bucket_object_lock_configuration" "backup_test" {
  bucket = module.backup_test.bucket_name

  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = 1
    }
  }
}

resource "kubernetes_secret" "backup_test" {
  metadata {
    name      = "backup-test-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.backup_test.bucket_arn
    bucket_name = module.backup_test.bucket_name
  }
}

# --- Write-only role, mirroring the write-only design intended for DB-2/GH-2 ---

data "aws_iam_policy_document" "backup_test_write" {
  statement {
    sid    = "PutTestBackupObjects"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:AbortMultipartUpload",
    ]
    resources = ["${module.backup_test.bucket_arn}/*"]
  }

  statement {
    sid       = "ListMultipartUploadsForTestBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucketMultipartUploads"]
    resources = [module.backup_test.bucket_arn]
  }
}

resource "aws_iam_policy" "backup_test_write" {
  name        = "${var.namespace}-backup-test-write-policy"
  description = "Write-only access for test CronJob(s) writing to the backup-test S3 bucket. No get/list/delete."
  policy      = data.aws_iam_policy_document.backup_test_write.json
}

module "irsa_backup_test_write" {
  source                = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name      = var.eks_cluster_name
  service_account_name  = "irsa-laa-landing-page-${var.environment}-backup-test-write"
  namespace             = var.namespace

  role_policy_arns = {
    backup_test_write = aws_iam_policy.backup_test_write.arn
  }
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name               = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "backup_test_github_mirror_assume" {
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

    # Scoped to the "development" GitHub Environment specifically (not just the
    # repo, and not "*" for any branch/ref) — only workflow runs deployed against
    # that Environment can assume this role.
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:ministryofjustice/laa-landing-page:environment:development"]
    }
  }
}

resource "aws_iam_role" "backup_test_github_mirror" {
  name               = "${var.namespace}-backup-test-github-mirror"
  assume_role_policy = data.aws_iam_policy_document.backup_test_github_mirror_assume.json

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

data "aws_iam_policy_document" "backup_test_github_mirror_write" {
  statement {
    sid    = "PutGithubMirrorTestObjects"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:AbortMultipartUpload",
    ]
    resources = ["${module.backup_test.bucket_arn}/github-mirror-test/*"]
  }

  statement {
    sid       = "ListMultipartUploadsForGithubMirrorTestPrefix"
    effect    = "Allow"
    actions   = ["s3:ListBucketMultipartUploads"]
    resources = [module.backup_test.bucket_arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["github-mirror-test/*"]
    }
  }
}

resource "aws_iam_policy" "backup_test_github_mirror_write" {
  name        = "${var.namespace}-backup-test-github-mirror-write-policy"
  description = "Write-only access for the dev-test GitHub mirror-backup workflow, scoped to the github-mirror-test/ prefix only. No get/list/delete."
  policy      = data.aws_iam_policy_document.backup_test_github_mirror_write.json
}

resource "aws_iam_role_policy_attachment" "backup_test_github_mirror_write" {
  role       = aws_iam_role.backup_test_github_mirror.name
  policy_arn = aws_iam_policy.backup_test_github_mirror_write.arn
}

# Published to the repo's existing "development" GitHub Environment (already used
# by serviceaccount.tf / ecr.tf), so the workflow reads them the same way
# deploy_dev.yml reads ECR_ROLE_TO_ASSUME.
resource "github_actions_environment_secret" "backup_test_github_mirror_role" {
  repository      = "laa-landing-page"
  environment     = "development"
  secret_name     = "BACKUP_TEST_S3_ROLE_TO_ASSUME"
  plaintext_value = aws_iam_role.backup_test_github_mirror.arn
}

resource "github_actions_environment_variable" "backup_test_bucket_name" {
  repository    = "laa-landing-page"
  environment   = "development"
  variable_name = "BACKUP_TEST_S3_BUCKET_NAME"
  value         = module.backup_test.bucket_name
}

resource "github_actions_environment_variable" "backup_test_region" {
  repository    = "laa-landing-page"
  environment   = "development"
  variable_name = "BACKUP_TEST_S3_REGION"
  value         = "eu-west-2"
}

# --- Temporary cleanup role: delete all objects + all versions, for the ---
# --- ephemeral pod used to empty the bucket once testing is complete.   ---

data "aws_iam_policy_document" "backup_test_cleanup" {
  statement {
    sid    = "ListForCleanup"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:ListBucketVersions",
    ]
    resources = [module.backup_test.bucket_arn]
  }

  statement {
    sid    = "DeleteAllTestObjectsAndVersions"
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      # Required because the bucket has a GOVERNANCE-mode Object Lock default
      # retention (see aws_s3_bucket_object_lock_configuration.backup_test).
      # The caller must also send x-amz-bypass-governance-retention:true
      # (aws s3api delete-object --bypass-governance-retention) on each delete.
      "s3:BypassGovernanceRetention",
    ]
    resources = ["${module.backup_test.bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "backup_test_cleanup" {
  name        = "${var.namespace}-backup-test-cleanup-policy"
  description = "TEMPORARY: full delete + governance-bypass rights on the backup-test bucket, for the one-off ephemeral cleanup pod. Attach to no other workload; remove after use."
  policy      = data.aws_iam_policy_document.backup_test_cleanup.json
}

module "irsa_backup_test_cleanup" {
  source                = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name      = var.eks_cluster_name
  service_account_name  = "irsa-laa-landing-page-${var.environment}-backup-test-cleanup"
  namespace             = var.namespace

  role_policy_arns = {
    backup_test_cleanup = aws_iam_policy.backup_test_cleanup.arn
  }
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name               = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
