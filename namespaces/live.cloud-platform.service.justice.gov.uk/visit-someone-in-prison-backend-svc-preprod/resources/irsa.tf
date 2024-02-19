# Add the names of the SQS/SNS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS/SNS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-15b2b4a6af7714848baeaf5f41c85fcd" = "hmpps-domain-events-preprod",
  }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }

  all_policies = merge(
    {
      hmpps_prison_visits_event_index_queue                           = module.hmpps_prison_visits_event_queue.irsa_policy_arn,
      hmpps_prison_visits_event_index_dead_letter_queue               = module.hmpps_prison_visits_event_dead_letter_queue.irsa_policy_arn,
      hmpps_prison_visits_notification_alerts_index_queue             = module.hmpps_prison_visits_notification_alerts_queue.irsa_policy_arn,
      hmpps_prison_visits_notification_alerts_index_dead_letter_queue = module.hmpps_prison_visits_notification_alerts_dead_letter_queue.irsa_policy_arn,
    },
  local.sns_policies)
}

data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}


module "irsa" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  namespace            = var.namespace
  service_account_name = var.application
  role_policy_arns     = local.all_policies

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name
}
