locals {
  oidc_provider = "token.actions.githubusercontent.com"
}

data "aws_iam_openid_connect_provider" "github" {
  url = "https://${local.oidc_provider}"
}

resource "aws_iam_role" "github" {
  name               = "operations-engineering-github-repos-prod-role"
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
      values   = ["repo:ministryofjustice/operations-engineering:*"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "s3_access_policy_document" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      module.s3_bucket.bucket_arn,
      "${module.s3_bucket.bucket_arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "dynamodb_state_lock_policy" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
    ]
    resources = [
      module.github_repos_prod_state_lock_table.table_arn
    ]
  }
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "github_role_prod_s3_access_policy"
  policy      = data.aws_iam_policy_document.s3_access_policy_document.json
}

resource "aws_iam_policy" "dynamodb_state_lock" {
  name   = "github-repos-prod-dynamodb-state-lock-policy"
  policy = data.aws_iam_policy_document.dynamodb_state_lock_policy.json
}

resource "aws_iam_role_policy_attachment" "github_role_perms_attachment" {
  role       = aws_iam_role.github.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "dynamodb_state_lock_attachment" {
  role       = aws_iam_role.github.name
  policy_arn = aws_iam_policy.dynamodb_state_lock.arn
}

resource "github_actions_secret" "role_arn" {
  repository      = var.repository_name
  secret_name     = "TERRAFORM_GITHUB_REPOS_S3_ROLE_ARN_PROD"
  plaintext_value = aws_iam_role.github.arn
}

