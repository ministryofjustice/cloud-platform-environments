module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.team_name}-${var.environment_name}"
  role_policy_arns = {
    s3            = module.s3_bucket.irsa_policy_arn
    migration     = aws_iam_policy.migration_policy.arn
    s3_new_bucket = module.s3_bucket_v2.irsa_policy_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace # this is also used to attach your service account to your namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}
