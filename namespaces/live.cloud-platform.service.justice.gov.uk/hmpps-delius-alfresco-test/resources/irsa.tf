data "aws_iam_policy" "poc_env_bucket_policy" {
  name = "cloud-platform-s3-5ce784402d8052fe1cd006f1e7329f70"
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.team_name}-${var.environment_name}"
  role_policy_arns = {
    amq            = aws_iam_policy.amq.arn
    s3             = module.s3_bucket.irsa_policy_arn
    s3_refresh_poc = data.aws_iam_policy.poc_env_bucket_policy.arn
    migration      = aws_iam_policy.migration_policy.arn
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
