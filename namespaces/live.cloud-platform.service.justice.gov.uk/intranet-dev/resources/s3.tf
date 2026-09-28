locals {
  github_repository = "intranet"
  # The GitHub Actions environment that deploys this namespace.
  # dev -> development, demo -> demo, staging -> staging, production -> production
  github_environment = "development"
}

module "s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3_bucket.bucket_arn
    bucket_name = module.s3_bucket.bucket_name
  }
}


########################################################################
# Let the intranet deploy workflow push build assets to the bucket.
#
# Self-managed rather than the module's `oidc_providers` input, because
# that attaches the full IRSA policy (every action, whole bucket) and
# trusts any branch in the repo. This is scoped to the build/ prefix,
# the actions s3-push-start.sh uses, and the deploy job's environment.
########################################################################

data "aws_region" "current" {
  provider = aws.london
}

data "aws_iam_openid_connect_provider" "github" {
  provider = aws.london
  url      = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "github_assume_role" {
  provider = aws.london
  version  = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    # Only the deploy job running against this environment, not any branch.
    #
    # Two subject formats: the original name-based one, and the immutable one
    # (numeric owner and repo IDs) that GitHub issues for repos created,
    # renamed or transferred after 15 July 2026.
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:ministryofjustice/${local.github_repository}:environment:${local.github_environment}",
        "repo:ministryofjustice@*/${local.github_repository}@*:environment:${local.github_environment}",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "github" {
  provider           = aws.london
  name               = "cloud-platform-${var.namespace}-github-s3"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
}

data "aws_iam_policy_document" "github_s3" {
  provider = aws.london
  version  = "2012-10-17"

  statement {
    sid       = "ListBuildObjects"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [module.s3_bucket.bucket_arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["build/*"]
    }
  }

  statement {
    sid    = "WriteBuildObjects"
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
    ]
    resources = ["${module.s3_bucket.bucket_arn}/build/*"]
  }
}

resource "aws_iam_role_policy" "github" {
  provider = aws.london
  name     = "s3-build-assets"
  role     = aws_iam_role.github.name
  policy   = data.aws_iam_policy_document.github_s3.json
}

# Consumed by .github/workflows/deploy.yml in the intranet repo.
resource "github_actions_environment_secret" "s3_role_to_assume" {
  repository      = local.github_repository
  environment     = local.github_environment
  secret_name     = "S3_ROLE_TO_ASSUME"
  plaintext_value = aws_iam_role.github.arn
}

resource "github_actions_environment_variable" "s3_bucket_name" {
  repository    = local.github_repository
  environment   = local.github_environment
  variable_name = "S3_BUCKET_NAME"
  value         = module.s3_bucket.bucket_name
}

resource "github_actions_environment_variable" "s3_region" {
  repository    = local.github_repository
  environment   = local.github_environment
  variable_name = "S3_REGION"
  value         = data.aws_region.current.name
}
