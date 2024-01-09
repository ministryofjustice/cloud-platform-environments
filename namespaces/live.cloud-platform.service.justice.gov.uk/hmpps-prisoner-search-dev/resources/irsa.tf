locals {
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573" = "hmpps-domain-events-dev"
  }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
}

module "hmpps-prisoner-search-indexer" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-prisoner-search-indexer"
  role_policy_arns = merge({
    hmpps_prisoner_search_index_queue               = module.hmpps_prisoner_search_index_queue.irsa_policy_arn,
    hmpps_prisoner_search_index_dead_letter_queue   = module.hmpps_prisoner_search_index_dead_letter_queue.irsa_policy_arn,
    hmpps_prisoner_search_domain_queue              = module.hmpps_prisoner_search_domain_queue.irsa_policy_arn,
    hmpps_prisoner_search_domain_dlq                = module.hmpps_prisoner_search_domain_dlq.irsa_policy_arn,
    hmpps_prisoner_search_offender_queue            = module.hmpps_prisoner_search_offender_queue.irsa_policy_arn,
    hmpps_prisoner_search_offender_dlq              = module.hmpps_prisoner_search_offender_dlq.irsa_policy_arn,
    hmpps_prisoner_search_publish_queue             = module.hmpps_prisoner_search_publish_queue.irsa_policy_arn,
    hmpps_prisoner_search_publish_dead_letter_queue = module.hmpps_prisoner_search_publish_dead_letter_queue.irsa_policy_arn,
  }, local.sns_policies)

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}
