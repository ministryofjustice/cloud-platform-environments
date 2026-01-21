# Add the names of the SQS/SNS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS/SNS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  rds_policies = {
    prison_visits_rds = module.prison-visits-rds.irsa_policy_arn
  }
}

module "irsa" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  namespace            = var.namespace
  service_account_name = var.application
  role_policy_arns     = local.rds_policies

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name
}

# set up the service pod
module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.2.0"

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name # this uses the service account name from the irsa module
}
