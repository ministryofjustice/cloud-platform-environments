module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "fraud-and-corruption-insights-sa"
  namespace            = var.namespace

  role_policy_arns = {
    "dynamodb-cluster" = module.dynamodb-cluster.role_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.2.0" 
  
  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name # this uses the service account name from the irsa module
}
