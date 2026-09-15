module "service_pod_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # KS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "cica-review-case-documents-dev-service-pod"
  namespace            = var.namespace

  # ECR read access for service pod
  role_policy_arns = {
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

  namespace            = var.namespace
  service_account_name = module.service_pod_irsa.service_account.name
}
