
locals {
  sqs_policies = {
    hmpps_court_data_ingestion_queue             = module.hmpps_court_data_ingestion_queue.irsa_policy_arn,
    hmpps_court_data_ingestion_dead_letter_queue = module.hmpps_court_data_ingestion_dead_letter_queue.irsa_policy_arn,
  }
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-court-data-ingestion-api"
  role_policy_arns     = merge(local.sqs_policies, { rds_policy = module.hmpps-court-data-ingestion-api-rds.irsa_policy_arn })
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
