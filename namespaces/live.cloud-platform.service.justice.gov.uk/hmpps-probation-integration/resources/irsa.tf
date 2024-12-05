data "aws_iam_policy" "sqs_access" {
  for_each = toset([
    "hmpps-probation-integration-services-dev-queue-policy",
    "hmpps-probation-integration-services-dev-dlq-policy",
    "hmpps-probation-integration-services-preprod-queue-policy",
    "hmpps-probation-integration-services-preprod-dlq-policy",
    "hmpps-probation-integration-services-prod-queue-policy",
    "hmpps-probation-integration-services-prod-dlq-policy",
  ])
  name = each.value
}

module "shared-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = var.application
  role_policy_arns     = {for key, policy in data.aws_iam_policy.sqs_access : key => policy.arn}
}
