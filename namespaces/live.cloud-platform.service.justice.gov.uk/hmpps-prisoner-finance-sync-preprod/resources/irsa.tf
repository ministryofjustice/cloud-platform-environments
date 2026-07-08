# Add the names of the SQS & SNS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-15b2b4a6af7714848baeaf5f41c85fcd" = "hmpps-domain-events-preprod"
  }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
  irsa_policies = merge(local.sns_policies, {    
    prisoner_finance_sync_queue_for_domain_events             = module.prisoner_finance_sync_queue_for_domain_events.irsa_policy_arn
    prisoner_finance_sync_queue_for_domain_events_dead_letter_queue = module.prisoner_finance_sync_queue_for_domain_events_dead_letter_queue.irsa_policy_arn

  })
}

module "hmpps_prisoner_finance_sync_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = var.application
  role_policy_arns     = local.irsa_policies
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