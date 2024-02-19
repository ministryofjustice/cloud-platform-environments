module "irsa_laa_test_viewer" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  namespace            = "laa-test-viewer"
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "laa-test-viewer-sa"
  role_policy_arns = {
    cross_irsa = module.s3_bucket.irsa_policy_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "irsa_laa_test_viewer" {
  metadata {
    name      = "irsa-output"
    namespace = "laa-test-viewer"
  }
  data = {
    role           = module.irsa_laa_test_viewer.role_name
    rolearn        = module.irsa_laa_test_viewer.role_arn
    serviceaccount = module.irsa_laa_test_viewer.service_account.name
  }
}
