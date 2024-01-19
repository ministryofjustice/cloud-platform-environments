locals {
  datahub_roles = [
    "arn:aws:iam::593291632749:role/openmetadata",
    "arn:aws:iam::013433889002:role/openmetadata"
  ]
}

data "aws_iam_policy_document" "datahub" {
  statement {
    sid       = "AllowAssumeRole"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = formatlist("%s", local.datahub_roles)
  }
}

resource "aws_iam_policy" "datahub" {
  name        = "datahub-policy"
  path        = "/"
  description = "Datahub Policy for Data Ingestion"
  policy      = data.aws_iam_policy_document.datahub.json
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0" # use the latest release

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.team_name}-${var.environment}"
  role_policy_arns = {
    datahub = aws_iam_policy.datahub.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace # this is also used to attach your service account to your namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}