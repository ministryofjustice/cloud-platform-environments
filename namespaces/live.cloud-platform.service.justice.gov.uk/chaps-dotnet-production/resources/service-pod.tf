# Setting up a service pod
# irsa configuration is required to use the service pod
module "irsa_service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.namespace}-service-account"
  namespace            = var.namespace # this is also used as a tag

  # Policies for AWS resources accessed via the service pod
  role_policy_arns = {
    rds = module.rds_mssql.irsa_policy_arn
    ecr = module.ecr.irsa_policy_arn
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
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.2.1"

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa_service_pod.service_account_name.name # this uses the service account name from the irsa module
}

