
module "analytical-platform" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  namespace              = var.namespace
  eks_cluster_name       = var.eks_cluster_name
  role_policy_arns       = {
    analytical-platform = aws_iam_policy.analytical-platform.arn
  }
  service_account_name   = "${var.namespace}-analytical-platform"
  # Tags
  business_unit          = var.business_unit
  team_name              = var.team_name
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}