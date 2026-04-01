locals {
  sqs_queues = {
    "Digital-Prison-Services-dev-cvl_domain_events_queue" = "hmpps-domain-events-dev",
    "Digital-Prison-Services-dev-cvl_domain_events_dead_letter_queue" = "hmpps-domain-events-dev",
  }
  sqs_policies = {
    cvl_domain_events_queue             = module.cvl_domain_events_queue.irsa_policy_arn,
    cvl_domain_events_dead_letter_queue = module.cvl_domain_events_dead_letter_queue.irsa_policy_arn,
    cvl_prison_events_queue             = module.cvl_prison_events_queue.irsa_policy_arn,
    cvl_prison_events_dead_letter_queue = module.cvl_prison_events_dead_letter_queue.irsa_policy_arn,
  }

  sns_topics = {
    "cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573" = "hmpps-domain-events-dev"
  }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = var.application
  role_policy_arns     = merge(local.sns_policies, local.sqs_policies, { rds_policy = module.create_and_vary_a_licence_api_rds.irsa_policy_arn })
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
