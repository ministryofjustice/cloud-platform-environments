# Add outputs that need to be consumed in other namespaces here.

locals {
  sqs_irsa_policies = {
    (module.cvl_domain_events_queue.sqs_name)                                       = module.cvl_domain_events_queue.irsa_policy_arn,
    (module.cvl_domain_events_dead_letter_queue.sqs_name)                           = module.cvl_domain_events_dead_letter_queue.irsa_policy_arn,
    (module.curious_queue.sqs_name)                                                 = module.curious_queue.irsa_policy_arn,
    (module.curious_dead_letter_queue.sqs_name)                                     = module.curious_dead_letter_queue.irsa_policy_arn,
    (module.activities_domain_events_queue.sqs_name)                                = module.activities_domain_events_queue.irsa_policy_arn,
    (module.activities_domain_events_dead_letter_queue.sqs_name)                    = module.activities_domain_events_dead_letter_queue.irsa_policy_arn,
    (module.education_and_work_plan_domain_events_queue.sqs_name)                   = module.education_and_work_plan_domain_events_queue.irsa_policy_arn,
    (module.education_and_work_plan_domain_events_dead_letter_queue.sqs_name)       = module.education_and_work_plan_domain_events_dead_letter_queue.irsa_policy_arn,
    (module.keyworker_api_queue.sqs_name)                                           = module.keyworker_api_queue.irsa_policy_arn,
    (module.hdc_domain_events_queue.sqs_name)                                       = module.hdc_domain_events_queue.irsa_policy_arn,
    (module.hdc_domain_events_dead_letter_queue.sqs_name)                           = module.hdc_domain_events_dead_letter_queue.irsa_policy_arn,
    (module.keyworker_api_dead_letter_queue.sqs_name)                               = module.keyworker_api_dead_letter_queue.irsa_policy_arn,
    (module.in_cell_queue.sqs_name)                                                 = module.in_cell_queue.irsa_policy_arn,
    (module.in_cell_dead_letter_queue.sqs_name)                                     = module.in_cell_dead_letter_queue.irsa_policy_arn,
    (module.whereabouts_api_domain_events_queue.sqs_name)                           = module.whereabouts_api_domain_events_queue.irsa_policy_arn,
    (module.whereabouts_api_domain_events_dead_letter_queue.sqs_name)               = module.whereabouts_api_domain_events_dead_letter_queue.irsa_policy_arn
  }

  sns_irsa_policies = {
    (module.hmpps-domain-events.topic_name) = module.hmpps-domain-events.irsa_policy_arn
  }
}

resource "aws_ssm_parameter" "tf-outputs-sqs-irsa-policies" {
  for_each = local.sqs_irsa_policies
  type     = "String"
  name     = "/${var.namespace}/sqs/${each.key}/irsa-policy-arn"
  value    = each.value
  tags     = local.tags
}

resource "aws_ssm_parameter" "tf-outputs-sns-irsa-policies" {
  for_each = local.sns_irsa_policies
  type     = "String"
  name     = "/${var.namespace}/sns/${each.key}/irsa-policy-arn"
  value    = each.value
  tags     = local.tags
}
