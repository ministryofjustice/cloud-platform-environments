module "hmpps-pfs-web-analytics-irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-pfs-web-analytics"
  role_policy_arns = {
    (module.hmpps_pfs_web_analytics_queue.sqs_name) = module.hmpps_pfs_web_analytics_queue.irsa_policy_arn
  }
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}