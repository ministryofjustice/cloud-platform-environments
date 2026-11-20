module "hmpps_pfs_web_analytics_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-pfs-web-analytics"
  role_policy_arns = {
    (module.hmpps_pfs_web_analytics_queue.sqs_name) = module.hmpps_pfs_web_analytics_queue.irsa_policy_arn
    (module.hmpps_pfs_web_analytics_dlq.sqs_name)   = module.hmpps_pfs_web_analytics_dlq.irsa_policy_arn
    rds                                             = module.rds.irsa_policy_arn
    (module.hmpps_pfs_common.topic_name)            = module.hmpps_pfs_common.irsa_policy_arn
    (module.hmpps_pfs_analytics.topic_name)         = module.hmpps_pfs_analytics.irsa_policy_arn
    (module.hmpps_pfs_audit.topic_name)             = module.hmpps_pfs_audit.irsa_policy_arn
  }
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

# dev-only service pod for testing
module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.3.0"

  namespace            = var.namespace
  service_account_name = module.hmpps_pfs_web_analytics_irsa.service_account.name
}