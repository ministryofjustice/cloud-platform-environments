module "moj_dashboard_prod_s3_read_irsa" {
  source                = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name      = var.eks_cluster_name
  namespace             = var.namespace
  service_account_name  = "moj-dashboard-prod-s3-read"
  role_policy_arns = {
    s3_read_policy = aws_iam_policy.moj_dashboard_prod_s3_read.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = false
  environment_name       = var.environment
  team_name              = var.team_name
  infrastructure_support = var.infrastructure_support
}

data "aws_iam_policy_document" "moj_dashboard_prod_s3_read" {
  # Permissions to read snapshot from s3 bucket
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${module.s3_bucket.bucket_arn}/*"
    ]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      module.s3_bucket.bucket_arn
    ]
  }
}

resource "aws_iam_policy" "moj_dashboard_prod_s3_read" {
  name   = "moj-dashboard-prod-s3-read"
  policy = data.aws_iam_policy_document.moj_dashboard_prod_s3_read.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = false
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "s3_read_irsa" {
  metadata {
    name      = "moj-dashboard-prod-s3-read-irsa-output"
    namespace = var.namespace
  }
  data = {
    role           = module.moj_dashboard_prod_s3_read_irsa.role_name
    rolearn        = module.moj_dashboard_prod_s3_read_irsa.role_arn
    serviceaccount = module.moj_dashboard_prod_s3_read_irsa.service_account.name
  }
}
