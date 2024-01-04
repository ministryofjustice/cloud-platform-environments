module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "justice-gov-uk-dev-service"
  namespace            = var.namespace # this is also used as a tag

  role_policy_arns = {
    s3  = module.s3_bucket.irsa_policy_arn,
    ecr = module.ecr_credentials.irsa_policy_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
