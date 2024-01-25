locals {
  sqs_queues = {
    "Digital-Prison-Services-${var.environment}-hmpps_audit_queue" = "hmpps-audit-${var.environment}",
  }
  sqs_policies = {for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value}
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}

module "download_api_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "hmpps-prisoner-download-api"
  namespace            = var.namespace

  role_policy_arns = merge(
    local.sqs_policies,
    { s3 = module.hmpps-prisoner-download_s3_bucket.irsa_policy_arn },
  )

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
