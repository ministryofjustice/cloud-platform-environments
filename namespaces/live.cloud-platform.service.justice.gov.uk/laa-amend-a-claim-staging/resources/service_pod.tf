module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # IRSA configuration
  service_account_name = "laa-amend-a-claim-staging-sa"
  namespace            = var.namespace
  role_policy_arns = {
    elasticache_redis = module.elasticache_redis.irsa_policy_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

}

# set up the service pod
module "ap_service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.2.1" # use the latest release

  # Configuration
  namespace            = var.namespace
  service_account_name = module.ap_irsa.service_account.name # this uses the service account name from the irsa module
}
