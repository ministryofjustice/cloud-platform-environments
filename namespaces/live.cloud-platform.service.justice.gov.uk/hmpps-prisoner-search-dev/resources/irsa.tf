module "hmpps-prisoner-search-indexer" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-prisoner-search-indexer"
  role_policy_arns = {
    hmpps_prisoner_search_index_queue             = module.hmpps_prisoner_search_index_queue.irsa_policy_arn,
    hmpps_prisoner_search_index_dead_letter_queue = module.hmpps_prisoner_search_index_dead_letter_queue.irsa_policy_arn,
    domain-events-sns-topic                       = data.aws_ssm_parameter.domain-events-sns-topic.value
  }
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "domain-events-sns-topic" {
  name = "/hmpps-domain-events-dev/sns/cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573/irsa-policy-arn"
}

