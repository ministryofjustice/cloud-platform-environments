module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.team_name}-${var.environment}"
  namespace            = var.namespace # this is also used as a tag


  role_policy_arns = {
    cemo_rds    = module.cemo_rds.irsa_policy_arn
    cemo_s3     = module.cemo_s3.irsa_policy_arn
    cemo_sqs    = module.cemo_submit_queue.irsa_policy_arn
    cemo_dl_sqs = module.cemo_submit_dl_queue.irsa_policy_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
