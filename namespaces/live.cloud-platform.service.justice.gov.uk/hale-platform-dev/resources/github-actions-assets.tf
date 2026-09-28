/*
 * A GitHub Actions role that can publish compiled theme assets to the
 * existing S3 bucket, and nothing else.
 */

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "assets_publisher_assume" {
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

    /*
     * Scoped to one repo AND one environment. The buildImage job declares
     * `environment: Development` (via inputs.environment in
     * rw-build-image.yaml), so its OIDC token carries this exact subject.
     * A workflow in another repo - or in this repo but targeting a different
     * environment - cannot assume this role.
     */
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:ministryofjustice/hale-platform:environment:Development"]
    }
  }
}

resource "aws_iam_role" "assets_publisher" {
  name_prefix        = "hale-assets-"
  description        = "Publishes compiled theme assets from GitHub Actions to the ${var.environment} asset bucket"
  assume_role_policy = data.aws_iam_policy_document.assets_publisher_assume.json

  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }
}

data "aws_iam_policy_document" "assets_publisher" {
  statement {
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "${module.s3_bucket.bucket_arn}/assets/*",
    ]
  }
}

resource "aws_iam_role_policy" "assets_publisher" {
  name_prefix = "assets-publish-"
  role        = aws_iam_role.assets_publisher.id
  policy      = data.aws_iam_policy_document.assets_publisher.json
}

resource "github_actions_environment_secret" "assets_publisher_role" {
  repository      = "hale-platform"
  environment     = "Development"
  secret_name     = "ASSET_ROLE_TO_ASSUME"
  plaintext_value = aws_iam_role.assets_publisher.arn
}
