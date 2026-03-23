module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=version" # use the latest release

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.team_name}-${var.environment}"
  role_policy_arns = {
    ssm = aws_iam_policy.ssm_access.arn
    cross_account_access = aws_iam_policy.athena_access.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
