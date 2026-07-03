module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "${var.application}-${var.environment}-sa"

  role_policy_arns = {
    s3 = module.s3_bucket.irsa_policy_arn
  }

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "github_actions_environment_variable" "app_role_arn" {
  repository    = "onboarding-optimisation"
  environment   = "dev"
  variable_name = "APP_ROLE_ARN"
  value         = module.irsa.role_arn
}
