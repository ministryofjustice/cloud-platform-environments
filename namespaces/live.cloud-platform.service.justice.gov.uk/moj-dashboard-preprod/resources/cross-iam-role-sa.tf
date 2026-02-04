module "moj_dashboard_preprod_irsa" {
  source                = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name      = var.eks_cluster_name
  namespace             = var.namespace
  service_account_name  = "moj-dashboard-preprod-cp-data-access"
  role_policy_arns = {
    data_access_policy = aws_iam_policy.moj_dashboard_preprod.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = false
  environment_name       = var.environment
  team_name              = var.team_name
  infrastructure_support = var.infrastructure_support
}

data "aws_iam_policy_document" "moj_dashboard_preprod" {
  # Permission to get data from athena (via ap) to create data snapshot
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::593291632749:role/alpha_app_mbpr-test"
    ]
  }
  # Permission to wite the snapshot to s3 bucket
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${module.s3_bucket.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "moj_dashboard_preprod" {
  name   = "moj-dashboard-preprod"
  policy = data.aws_iam_policy_document.moj_dashboard_preprod.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = false
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "moj-dashboard-preprod-irsa-output"
    namespace = var.namespace
  }
  data = {
    role           = module.moj_dashboard_preprod_irsa.role_name
    rolearn        = module.moj_dashboard_preprod_irsa.role_arn
    serviceaccount = module.moj_dashboard_preprod_irsa.service_account.name
  }
}
