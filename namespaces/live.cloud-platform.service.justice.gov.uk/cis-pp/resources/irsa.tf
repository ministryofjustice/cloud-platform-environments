module "irsa" {
  #checkov:skip=CKV_TF_1:Cloud Platform modules use version tags not commit hashes
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "${var.namespace}-frontend"
  namespace            = var.namespace

  role_policy_arns = {
    s3         = aws_iam_policy.frontend_s3_deploy.arn
    cloudfront = aws_iam_policy.frontend_cloudfront_invalidate.arn
  }

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "${var.namespace}-irsa"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.role_name
    serviceaccount = module.irsa.service_account.name
    rolearn        = module.irsa.role_arn
  }
}