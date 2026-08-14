module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name = var.eks_cluster_name

  service_account_name = "laa-data-access-prod-irsa"
  namespace            = var.namespace

  role_policy_arns = {
    data_access_events_sns = aws_iam_policy.data_access_events_publisher.arn
  }

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
  service_account_name = module.irsa.service_account.name
}
