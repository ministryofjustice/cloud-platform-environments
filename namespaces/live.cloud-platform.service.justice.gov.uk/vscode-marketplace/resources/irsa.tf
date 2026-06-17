# IRSA (IAM Roles for Service Accounts): pod identities for S3 access, with no
# static credentials. Two least-privilege roles, each bound to its own
# Kubernetes service account (created by the module):
#
#   * curator     - read/write/delete on the bucket objects (it publishes and
#                   prunes VSIX files and writes report artifacts).
#   * marketplace - read-only (its sidecar only syncs files down).
#
# The service account names here MUST match `serviceAccountName` in the curator
# CronJob and the marketplace Deployment manifests.

locals {
  policy_tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment_name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

# --- Curator: read / write / delete -------------------------------------------

data "aws_iam_policy_document" "curator_s3" {
  statement {
    sid       = "ListBucket"
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = [module.s3_bucket.bucket_arn]
  }
  statement {
    sid       = "ReadWriteDeleteObjects"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${module.s3_bucket.bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "curator_s3" {
  provider = aws.london
  name     = "${var.namespace}-curator-s3"
  policy   = data.aws_iam_policy_document.curator_s3.json
  tags     = local.policy_tags
}

module "curator_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "vscode-marketplace-curator"
  role_policy_arns     = { s3 = aws_iam_policy.curator_s3.arn }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

# --- Marketplace: read-only ---------------------------------------------------

data "aws_iam_policy_document" "marketplace_s3" {
  statement {
    sid       = "ListBucket"
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = [module.s3_bucket.bucket_arn]
  }
  statement {
    sid       = "ReadObjects"
    actions   = ["s3:GetObject"]
    resources = ["${module.s3_bucket.bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "marketplace_s3" {
  provider = aws.london
  name     = "${var.namespace}-marketplace-s3"
  policy   = data.aws_iam_policy_document.marketplace_s3.json
  tags     = local.policy_tags
}

module "marketplace_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "vscode-marketplace"
  role_policy_arns     = { s3 = aws_iam_policy.marketplace_s3.arn }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}
