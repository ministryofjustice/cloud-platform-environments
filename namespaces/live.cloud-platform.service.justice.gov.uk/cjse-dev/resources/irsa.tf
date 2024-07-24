module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "cjse-sa"
  namespace            = var.namespace # this is also used as a tag

  role_policy_arns = {
    unprocessed_sqs         = module.unprocessed_documents_and_events_sqs.irsa_policy_arn
    process_sqs             = module.process_sqs.irsa_policy_arn
    rds_mssql               = module.rds_mssql.irsa_policy_arn
    dynamodb                = module.dynamodb-cluster.irsa_policy_arn
    notifications_sqs       = module.notifications_sqs.irsa_policy_arn
    ingestion_api_ecr       = module.ingestion_api_ecr.irsa_policy_arn
    ingestion_processor_ecr = module.ingestion_processor_ecr.irsa_policy_arn
    webportal_ecr           = module.webportal_ecr.irsa_policy_arn
    webportal_api_ecr       = module.webportal_api_ecr.irsa_policy_arn
    subscription_api_ecr    = module.subscription_api_ecr.irsa_policy_arn
    notification_api_ecr    = module.notification_api_ecr.irsa_policy_arn
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
module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.0.0" # use the latest release

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name # this uses the service account name from the irsa module
}
