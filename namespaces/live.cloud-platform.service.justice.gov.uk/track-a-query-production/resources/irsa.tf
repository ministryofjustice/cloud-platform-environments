module "irsa" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = var.application
  namespace            = var.namespace

  role_policy_arns = {
    s3                 = module.track_a_query_s3.irsa_policy_arn
    rds                = module.track_a_query_rds.irsa_policy_arn
    anonymiser_exports = aws_iam_policy.anonymiser_exports.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

locals {
  anonymiser_export_bucket_arn = "arn:aws:s3:::cloud-platform-a0145612d799b0edf7e1f7f20a0911fb"
}

data "aws_iam_policy_document" "anonymiser_exports" {
  statement {
    sid       = "ListLatestExports"
    actions   = ["s3:ListBucket"]
    resources = [local.anonymiser_export_bucket_arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["dumps/latest", "dumps/latest/*"]
    }
  }

  statement {
    sid = "ReplaceLatestExports"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:DeleteObject",
    ]
    resources = ["${local.anonymiser_export_bucket_arn}/dumps/latest/*"]
  }

  statement {
    sid       = "ReadAnonymiserUserSettings"
    actions   = ["s3:GetObject"]
    resources = ["${local.anonymiser_export_bucket_arn}/dumps/user_settings.json"]
  }
}

resource "aws_iam_policy" "anonymiser_exports" {
  name   = "${var.namespace}-anonymiser-exports"
  policy = data.aws_iam_policy_document.anonymiser_exports.json

  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }
}
