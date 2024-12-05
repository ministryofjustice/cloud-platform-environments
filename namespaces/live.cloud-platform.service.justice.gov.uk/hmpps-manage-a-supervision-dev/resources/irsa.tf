locals {
  sqs_queues = {
    "Digital-Prison-Services-${var.environment}-hmpps_audit_queue" = "hmpps-audit-${var.environment}",
  }
  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}

module "manage-a-supervision-ui-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "manage-a-supervision-ui"
  role_policy_arns = merge(
    { elasticache = module.elasticache.irsa_policy_arn },
    local.sqs_policies,
  )
}
