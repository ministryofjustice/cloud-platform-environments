locals {
  oidc_provider = "token.actions.githubusercontent.com"
}

data "aws_iam_openid_connect_provider" "github" {
  url = "https://${local.oidc_provider}"
}

resource "aws_iam_role" "github" {
  name = "offloc-transfer-gha-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.github.json
}

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
      test     = "StringLike"
      variable = "${local.oidc_provider}:sub"
      values   = ["repo:ministryofjustice/ansible-monorepo:*"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "offloc-transfer-gha-policy"
  description = "Policy to allow access to S3 bucket"
  policy      = data.aws_iam_policy_document.dso_user_s3_access_policy.json
}

resource "aws_iam_role_policy_attachment" "s3_access_policy_attachment" {
  role       = aws_iam_role.github.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "github_actions_secret" "role_arn" {
  repository = "ansible-monorepo"
  secret_name = "OFFLOC_TRANSFER_GHA_ROLE_ARN_${var.environment}"
  plaintext_value = aws_iam_role.github.arn
}

resource "github_actions_secret" "s3_bucket" {
  repository = "ansible-monorepo"
  secret_name = "OFFLOC_TRANSFER_S3_BUCKET_NAME_${var.environment}"
  plaintext_value = module.hmpps-prisoner-location_s3_bucket.bucket_name
}
