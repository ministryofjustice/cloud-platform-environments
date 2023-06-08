module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # Configuration
  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hello-world"

  role_policy_arns = {
    dynamodb = module.dynamodb.irsa_policy_arn,
    s3 = module.s3.irsa_policy_arn,
    sns = module.sns.irsa_policy_arn,
    sqs = module.sqs.irsa_policy_arn,
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
