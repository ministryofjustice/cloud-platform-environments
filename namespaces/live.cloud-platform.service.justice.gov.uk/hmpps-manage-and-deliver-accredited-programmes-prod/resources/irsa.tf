# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-97e6567cf80881a8a52290ff2c269b08" = "hmpps-domain-events-prod"
  }
  sqs_queues = {
    "Digital-Prison-Services-${var.environment}-hmpps_audit_queue" = "hmpps-audit-${var.environment}",
  }

  # The names of the SNS topics used and the namespace which created them
  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name       = var.eks_cluster_name
  namespace              = var.namespace
  service_account_name   = "hmpps-manage-and-deliver-accredited-programmes"

  role_policy_arns = merge(
    { elasticache = module.elasticache_redis.irsa_policy_arn },
    {
      sqs = module.mandd_queue.irsa_policy_arn
    },
    {
      sqs_dlq = module.mandd_dlq.irsa_policy_arn
    },
    local.sqs_policies,
    local.sns_policies
  )

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}
