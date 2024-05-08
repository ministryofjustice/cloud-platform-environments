module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0" # use the latest release

  eks_cluster_name = var.eks_cluster_name

  service_account_name = "laa-sds-serviceaccount-${var.environment}"
  role_policy_arns = {
    dynamodb = aws_iam_policy.auditdb_policy.arn
    s3       = aws_iam_policy.s3_policy.arn
  }

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}