module "s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.2.0"
  bucket_name            = "hmpps-probation-integration-gradle-cache"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
  lifecycle_rule = [
    {
      id         = "expiry"
      enabled    = true
      expiration = [{ days = 90 }]
    },
  ]
}

####################
# OIDC integration #
####################
data "aws_region" "current" {}
locals {
  # Identifiers
  oidc_identifier = "cloud-platform-s3-${random_id.oidc.hex}"

  # Providers
  oidc_providers = {
    github = "token.actions.githubusercontent.com"
  }

  # GitHub
  github_repos          = toset(["hmpps-probation-integration-services"])
  github_actions_prefix = "GRADLE_CACHE"
  github_variable_names = {
    ROLE_TO_ASSUME = join("_", compact([local.github_actions_prefix, "S3_ROLE_TO_ASSUME"]))
    REGION         = join("_", compact([local.github_actions_prefix, "S3_REGION"]))
    BUCKET_NAME    = join("_", compact([local.github_actions_prefix, "S3_BUCKET_NAME"]))
  }

  # Tags
  default_tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    namespace              = var.namespace
    environment-name       = var.environment_name
    infrastructure-support = var.infrastructure_support
  }
}

# Random ID for identifiers
resource "random_id" "oidc" {
  byte_length = 8
}

# IAM policy for reading/writing
data "aws_iam_policy_document" "s3" {
  version = "2012-10-17"

  statement {
    sid    = "ReadWrite"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = [
      module.s3_bucket.bucket_arn,
      "${module.s3_bucket.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3" {
  name   = local.oidc_identifier
  policy = data.aws_iam_policy_document.s3.json
  tags   = local.default_tags
}

# GitHub: OIDC provider
data "aws_iam_openid_connect_provider" "github" {
  url = "https://${local.oidc_providers.github}"
}

# GitHub: Assume role policy
# See: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services#adding-the-identity-provider-to-aws
data "aws_iam_policy_document" "github" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = (length(local.github_repos) == 1) ? "StringLike" : "ForAnyValue:StringLike"
      variable = "${local.oidc_providers.github}:sub"
      values   = formatlist("repo:ministryofjustice/%s:*", local.github_repos)
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_providers.github}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# IAM role and policy attachment
resource "aws_iam_role" "github" {
  name               = "${local.oidc_identifier}-github"
  assume_role_policy = data.aws_iam_policy_document.github.json

  tags = local.default_tags
}

resource "aws_iam_role_policy_attachment" "github" {
  role       = aws_iam_role.github.name
  policy_arn = aws_iam_policy.s3.arn
}

# Actions
resource "github_actions_secret" "role_to_assume" {
  for_each        = local.github_repos
  repository      = each.value
  secret_name     = local.github_variable_names["ROLE_TO_ASSUME"]
  plaintext_value = aws_iam_role.github.arn
}

resource "github_actions_variable" "region" {
  for_each      = local.github_repos
  repository    = each.value
  variable_name = local.github_variable_names["REGION"]
  value         = data.aws_region.current.name
}

resource "github_actions_variable" "bucket" {
  for_each      = local.github_repos
  repository    = each.value
  variable_name = local.github_variable_names["BUCKET_NAME"]
  value         = module.s3_bucket.bucket_name
}
