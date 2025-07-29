module "person-search-index-from-delius-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "person-search-index-from-delius"
  role_policy_arns = {
    contact-keyword-queue = module.person-search-index-from-delius-contact-keyword-queue.irsa_policy_arn,
    contact-queue = module.person-search-index-from-delius-contact-queue.irsa_policy_arn,
    person-queue  = module.person-search-index-from-delius-person-queue.irsa_policy_arn,
  }
}