module "doc_gen_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0" # use the latest release

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "hmpps-document-generation-api"
  role_policy_arns     = {
    rds = module.doc_gen_postgres.irsa_policy_arn
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