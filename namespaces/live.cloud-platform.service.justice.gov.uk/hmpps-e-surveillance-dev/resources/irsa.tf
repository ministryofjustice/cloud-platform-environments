module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0" # use the latest release

  # EKS configuration
  eks_cluster_name = var.kubernetes_cluster

  # IRSA configuration
  service_account_name = "${var.team_name}-${var.environment}"

  role_policy_arns = {
      s3  = module.s3.irsa_policy_arn
      rds = module.rds_instance.irsa_policy_arn
      sns = module.sns_topic_file_upload.irsa_policy_arn
    }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace # this is also used to attach your service account to your namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
