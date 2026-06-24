resource "aws_iam_policy" "frontend_s3_deploy" {
  name        = "${var.namespace}-frontend-s3-deploy"
  description = "Allow CI to sync static assets to the ${var.namespace} frontend S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListFrontendBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
        ]
        Resource = aws_s3_bucket.frontend.arn
      },
      {
        Sid    = "ManageFrontendObjects"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = "${aws_s3_bucket.frontend.arn}/*"
      },
    ]
  })
}

resource "aws_iam_policy" "frontend_cloudfront_invalidate" {
  name        = "${var.namespace}-frontend-cloudfront-invalidate"
  description = "Allow CI to invalidate the ${var.namespace} CloudFront distribution after deploy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "InvalidateFrontendDistribution"
        Effect = "Allow"
        Action = [
          "cloudfront:GetDistribution",
          "cloudfront:ListDistributions",
          "cloudfront:CreateInvalidation",
          "cloudfront:GetInvalidation",
          "cloudfront:ListInvalidations",
        ]
        Resource = aws_cloudfront_distribution.frontend.arn
      },
    ]
  })
}

# -----------------------------------------------------------------------------
# GitHub OIDC Role
#
# Allows GitHub Actions to assume an IAM role via OIDC to deploy the frontend application.
#
# Modified from the terraform-aws-modules/iam/aws//modules/iam-github-oidc-role module to allow for more flexible
# configuration of the trust policy, as the module does not currently support the `job_workflow_ref` condition
# key which is used to restrict access to specific workflow(s) on specific branch(es)
#
# References:
# https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-with-reusable-workflows
# https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_iam-condition-keys.html#condition-keys-wif
# https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/5.9.2/submodules/iam-github-oidc-role 
# -----------------------------------------------------------------------------
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

locals {
 # Just extra safety incase someone passes in a url with `https://`
  provider_url = replace(var.oidc_role_provider_url, "https://", "") 
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
}

data "aws_iam_policy_document" "github_oidc_policy" {
  statement {
    sid    = "GithubOidcAuth"
    effect = "Allow"
    actions = [
      "sts:TagSession",
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type        = "Federated"
      identifiers = ["arn:${local.partition}:iam::${local.account_id}:oidc-provider/${local.provider_url}"]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "${local.provider_url}:iss"
      values   = ["https://${local.provider_url}"]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "${local.provider_url}:aud"
      values   = ["${var.oidc_role_audience}"]
    }

    condition {
      test     = "StringLike"
      variable = "${local.provider_url}:sub"
      values   = ["repo:ministryofjustice/${var.github_repository}:environment:${var.environment}"]
    }

    condition {
      test     = "StringLike"
      variable = "${local.provider_url}:job_workflow_ref"
      values   = ["ministryofjustice/${var.github_repository}/${var.oidc_role_workflow_file}@refs/heads/${var.oidc_role_workflow_branch}"]
    }
  }
}

resource "aws_iam_role" "github_oidc_iam_role" {
  name_prefix = "${var.namespace}-github-oidc"
  path        = var.oidc_role_path

  assume_role_policy    = data.aws_iam_policy_document.github_oidc_policy.json
  force_detach_policies = var.oidc_role_force_detach_policies
}

resource "aws_iam_role_policy_attachment" "github_oidc_policy_attach_s3" {
  role       = aws_iam_role.github_oidc_iam_role.name
  policy_arn = aws_iam_policy.frontend_s3_deploy.arn
}

resource "aws_iam_role_policy_attachment" "github_oidc_policy_attach_cloudfront" {
  role       = aws_iam_role.github_oidc_iam_role.name
  policy_arn = aws_iam_policy.frontend_cloudfront_invalidate.arn
}

resource "kubernetes_secret" "github_oidc_iam_role" {
  metadata {
    name      = "github-oidc-iam-role"
    namespace = var.namespace
  }

  data = {
    role_arn = aws_iam_role.github_oidc_iam_role.arn
  }
}