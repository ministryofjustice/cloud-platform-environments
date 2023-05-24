module "hmpps-prisoner-search-indexer-irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.1.0"

  eks_cluster_name = var.eks_cluster_name
  namespace        = var.namespace
  service_account  = "hmpps-prisoner-search-indexer-dev"
  role_policy_arns = [
    module.hmpps_prisoner_search_index_queue.irsa_policy_arn,
    module.hmpps_prisoner_search_index_dead_letter_queue.irsa_policy_arn,
    data.aws_ssm_parameter.domain-events-sns-topic.value
  ]
}

data "aws_ssm_parameter" "domain-events-sns-topic" {
  name = "/hmpps-domain-events-dev/sns/cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573/irsa-policy-arn"
}

