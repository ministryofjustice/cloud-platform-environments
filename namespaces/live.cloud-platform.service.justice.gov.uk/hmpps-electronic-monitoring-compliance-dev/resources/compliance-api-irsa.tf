module "irsa" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name     = var.kubernetes_cluster
  service_account_name = var.namespace-short
  namespace            = var.namespace
  role_policy_arns     = merge(
    {
      datastore = aws_iam_policy.assume_datastore_role.arn
    }
  )

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
