data "aws_iam_policy_document" "document" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::${var.dp_dev_account}:role/${var.namespace}",
    ]
  }
}

resource "aws_iam_policy" "policy" {
  name        = "${var.namespace}-assume-role"
  path        = "/${var.namespace}/"
  policy      = data.aws_iam_policy_document.document.json
  description = "Policy for Cloud Platform Superset demo to assume role in data platform dev account"
}

module "irsa" {
  #always replace with latest version from Github
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.team_name}-${var.environment}"
  namespace            = var.namespace # this is also used as a tag
  role_policy_arns = {
    s3 = aws_iam_policy.policy.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "${var.team_name}-irsa"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.role_name
    serviceaccount = module.irsa.service_account.name
  }
}