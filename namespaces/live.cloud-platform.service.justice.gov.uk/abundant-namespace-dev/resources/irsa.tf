module "irsa" {
  #always replace with latest version from Github
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.team_name}-${var.environment}"
  namespace            = var.namespace # this is also used as a tag
  role_policy_arns = {
    aurora = module.aurora_db.irsa_policy_arn
    dynamo = module.example_team_dynamodb.irsa_policy_arn
    rds    = module.rds.irsa_policy_arn
    sns    = module.abundant_namespace_dev_sns.irsa_policy_arn
    sqs    = module.abundant_namespace_sqs.irsa_policy_arn
    s3     = module.s3_bucket.irsa_policy_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
