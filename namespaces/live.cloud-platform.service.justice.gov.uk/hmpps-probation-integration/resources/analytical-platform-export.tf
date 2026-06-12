locals {
  github_oidc_url        = "token.actions.githubusercontent.com"
  github_oidc_repository = "hmpps-probation-integration-services"
}

# GitHub: OIDC provider
data "aws_iam_openid_connect_provider" "github" {
  url = "https://${local.github_oidc_url}"
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
      test     = "StringLike"
      variable = "${local.github_oidc_url}:sub"
      values   = ["repo:${var.github_owner}/${local.github_oidc_repository}:*"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.github_oidc_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# IAM role and policy attachment for OIDC
resource "aws_iam_role" "github" {
  name               = "cloud-platform-probation-integration-to-analytical-platform"
  assume_role_policy = data.aws_iam_policy_document.github.json
}

data "aws_iam_policy_document" "s3_export" {
  statement {
    sid = "BucketActions"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = ["arn:aws:s3:::*"]
  }

  statement {
    sid = "ObjectActions"
    actions = [
      "s3:PutObject*",
      "s3:PutObjectAcl",
      "s3:GetObject*",
      "s3:DeleteObject*"
    ]
    resources = [
      "arn:aws:s3:::moj-reg-prod/landing/hmpps-probation-integration/*",
      "arn:aws:s3:::moj-reg-prod/landing/hmpps-probation-integration/"
    ]
  }
}

resource "aws_iam_policy" "s3_export" {
  name   = "cloud-platform-probation-integration-to-analytical-platform"
  policy = data.aws_iam_policy_document.s3_export.json
}

resource "aws_iam_role_policy_attachment" "github_s3_export" {
  role       = aws_iam_role.github.name
  policy_arn = aws_iam_policy.s3_export.arn
}

resource "github_actions_secret" "role_to_assume" {
  repository      = local.github_oidc_repository
  secret_name     = "ANALYTICAL_PLATFORM_EXPORT_S3_ROLE_TO_ASSUME"
  plaintext_value = aws_iam_role.github.arn
}

resource "github_actions_secret" "bucket_name" {
  repository      = local.github_oidc_repository
  secret_name     = "ANALYTICAL_PLATFORM_EXPORT_S3_BUCKET_NAME"
  plaintext_value = "moj-reg-prod"
}
