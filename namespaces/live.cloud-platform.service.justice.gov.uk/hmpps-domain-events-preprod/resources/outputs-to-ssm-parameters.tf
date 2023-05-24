# Add outputs that need to be consumed in other namespaces here.

locals {
  sqs_irsa_policies = {
    (module.cvl_domain_events_queue.sqs_name)                                       = module.cvl_domain_events_queue.irsa_policy_arn,
    (module.cvl_domain_events_dead_letter_queue.sqs_name)                           = module.cvl_domain_events_dead_letter_queue.irsa_policy_arn,
    (module.curious_queue.sqs_name)                                                 = module.curious_queue.irsa_policy_arn,
    (module.curious_dead_letter_queue.sqs_name)                                     = module.curious_dead_letter_queue.irsa_policy_arn,
    (module.hmpps_domain_event_logger_queue.sqs_name)                               = module.hmpps_domain_event_logger_queue.irsa_policy_arn,
    (module.hmpps_domain_event_logger_dead_letter_queue.sqs_name)                   = module.hmpps_domain_event_logger_dead_letter_queue.irsa_policy_arn,
    (module.keyworker_api_queue.sqs_name)                                           = module.keyworker_api_queue.irsa_policy_arn,
    (module.keyworker_api_dead_letter_queue.sqs_name)                               = module.keyworker_api_dead_letter_queue.irsa_policy_arn,
    (module.hmpps_prison_visits_event_queue.sqs_name)                               = module.hmpps_prison_visits_event_queue.irsa_policy_arn,
    (module.hmpps_prison_visits_event_dead_letter_queue.sqs_name)                   = module.hmpps_prison_visits_event_dead_letter_queue.irsa_policy_arn,
    (module.hmpps_prisoner_to_nomis_visit_queue.sqs_name)                           = module.hmpps_prisoner_to_nomis_visit_queue.irsa_policy_arn,
    (module.hmpps_prisoner_to_nomis_visit_dead_letter_queue.sqs_name)               = module.hmpps_prisoner_to_nomis_visit_dead_letter_queue.irsa_policy_arn,
    (module.hmpps_prisoner_to_nomis_incentive_queue.sqs_name)                       = module.hmpps_prisoner_to_nomis_incentive_queue.irsa_policy_arn,
    (module.hmpps_prisoner_to_nomis_incentive_dead_letter_queue.sqs_name)           = module.hmpps_prisoner_to_nomis_incentive_dead_letter_queue.irsa_policy_arn,
    (module.hmpps_prisoner_to_nomis_activity_queue.sqs_name)                        = module.hmpps_prisoner_to_nomis_activity_queue.irsa_policy_arn,
    (module.hmpps_prisoner_to_nomis_activity_dead_letter_queue.sqs_name)            = module.hmpps_prisoner_to_nomis_activity_dead_letter_queue.irsa_policy_arn,
    (module.prisoner_to_nomis_appointment_queue.sqs_name)                           = module.prisoner_to_nomis_appointment_queue.irsa_policy_arn,
    (module.prisoner_to_nomis_appointment_dead_letter_queue.sqs_name)               = module.prisoner_to_nomis_appointment_dead_letter_queue.irsa_policy_arn,
    (module.hmpps_prisoner_to_nomis_sentencing_queue.sqs_name)                      = module.hmpps_prisoner_to_nomis_sentencing_queue.irsa_policy_arn,
    (module.hmpps_prisoner_to_nomis_sentencing_dead_letter_queue.sqs_name)          = module.hmpps_prisoner_to_nomis_sentencing_dead_letter_queue.irsa_policy_arn,
    (module.restricted_patients_queue_for_domain_events.sqs_name)                   = module.restricted_patients_queue_for_domain_events.irsa_policy_arn,
    (module.restricted_patients_queue_for_domain_events_dead_letter_queue.sqs_name) = module.restricted_patients_queue_for_domain_events_dead_letter_queue.irsa_policy_arn,
    (module.in_cell_queue.sqs_name)                                                 = module.in_cell_queue.irsa_policy_arn,
    (module.in_cell_dead_letter_queue.sqs_name)                                     = module.in_cell_dead_letter_queue.irsa_policy_arn,
    (module.prisoner_offender_search_domain_queue.sqs_name)                         = module.prisoner_offender_search_domain_queue.irsa_policy_arn,
    (module.prisoner_offender_search_domain_dlq.sqs_name)                           = module.prisoner_offender_search_domain_dlq.irsa_policy_arn
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
