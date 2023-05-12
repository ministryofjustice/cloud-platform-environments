# Add outputs that need to be consumed in other namespaces here.

# This param needs to deleting after cut over to new config below.
resource "aws_ssm_parameter" "tf-outputs" {
  type = "String"
  name = "/${var.namespace}/tf-outputs"
  value = jsonencode({
    "restricted_patients_queue_irsa_policy_arn" : module.restricted_patients_queue.irsa_policy_arn
    "restricted_patients_dql_queue_irsa_policy_arn" : module.restricted_patients_dead_letter_queue.irsa_policy_arn
  })
  tags = local.tags
}

locals {
  sqs_irsa_policies = {
    (module.cfo_queue.sqs_name)                                                    = module.cfo_queue.irsa_policy_arn,
    (module.cfo_dead_letter_queue.sqs_name)                                        = module.cfo_dead_letter_queue.irsa_policy_arn,
    (module.cvl_prison_events_queue.sqs_name)                                      = module.cvl_prison_events_queue.irsa_policy_arn,
    (module.cvl_probation_events_queue.sqs_name)                                   = module.cvl_probation_events_queue.irsa_policy_arn,
    (module.cvl_prison_events_dead_letter_queue.sqs_name)                          = module.cvl_prison_events_dead_letter_queue.irsa_policy_arn,
    (module.cvl_probation_events_dead_letter_queue.sqs_name)                       = module.cvl_probation_events_dead_letter_queue.irsa_policy_arn,
    (module.hmpps_allocations_offender_events_queue.sqs_name)                      = module.hmpps_allocations_offender_events_queue.irsa_policy_arn,
    (module.hmpps_allocations_offender_events_dead_letter_queue.sqs_name)          = module.hmpps_allocations_offender_events_dead_letter_queue.irsa_policy_arn,
    (module.prisoner_from_nomis_sentencing_queue.sqs_name)                         = module.prisoner_from_nomis_sentencing_queue.irsa_policy_arn,
    (module.prisoner_from_nomis_sentencing_dead_letter_queue.sqs_name)             = module.prisoner_from_nomis_sentencing_dead_letter_queue.irsa_policy_arn,
    (module.prisoner_from_nomis_visits_queue.sqs_name)                             = module.prisoner_from_nomis_visits_queue.irsa_policy_arn,
    (module.prisoner_from_nomis_visits_dead_letter_queue.sqs_name)                 = module.prisoner_from_nomis_visits_dead_letter_queue.irsa_policy_arn,
    (module.restricted_patients_queue.sqs_name)                                    = module.restricted_patients_queue.irsa_policy_arn,
    (module.restricted_patients_dead_letter_queue.sqs_name)                        = module.restricted_patients_dead_letter_queue.irsa_policy_arn,
    (module.hmpps_tier_offender_events_queue.sqs_name)                             = module.hmpps_tier_offender_events_queue.irsa_policy_arn,
    (module.hmpps_tier_offender_events_dead_letter_queue.sqs_name)                 = module.hmpps_tier_offender_events_dead_letter_queue.irsa_policy_arn,
    (module.hmpps_workload_offender_events_queue.sqs_name)                         = module.hmpps_workload_offender_events_queue.irsa_policy_arn,
    (module.hmpps_workload_offender_events_dead_letter_queue.sqs_name)             = module.hmpps_workload_offender_events_dead_letter_queue.irsa_policy_arn,
    (module.keyworker_api_queue.sqs_name)                                          = module.keyworker_api_queue.irsa_policy_arn,
    (module.keyworker_api_dead_letter_queue.sqs_name)                              = module.keyworker_api_dead_letter_queue.irsa_policy_arn,
    (module.manage_soc_cases_offender_events_queue.sqs_name)                       = module.manage_soc_cases_offender_events_queue.irsa_policy_arn,
    (module.manage_soc_cases_probation_offender_events_queue.sqs_name)             = module.manage_soc_cases_probation_offender_events_queue.irsa_policy_arn,
    (module.manage_soc_cases_offender_events_dead_letter_queue.sqs_name)           = module.manage_soc_cases_offender_events_dead_letter_queue.irsa_policy_arn,
    (module.manage_soc_cases_probation_offender_events_dead_letter_queue.sqs_name) = module.manage_soc_cases_probation_offender_events_dead_letter_queue.irsa_policy_arn,
    (module.offender_case_notes_events_queue.sqs_name)                             = module.offender_case_notes_events_queue.irsa_policy_arn,
    (module.offender_case_notes_events_dead_letter_queue.sqs_name)                 = module.offender_case_notes_events_dead_letter_queue.irsa_policy_arn,
    (module.offender_categorisation_events_queue.sqs_name)                         = module.offender_categorisation_events_queue.irsa_policy_arn,
    (module.offender_categorisation_events_dead_letter_queue.sqs_name)             = module.offender_categorisation_events_dead_letter_queue.irsa_policy_arn,
    (module.offender_categorisation_ui_events_queue.sqs_name)                      = module.offender_categorisation_ui_events_queue.irsa_policy_arn,
    (module.offender_categorisation_ui_events_dead_letter_queue.sqs_name)          = module.offender_categorisation_ui_events_dead_letter_queue.irsa_policy_arn,
    (module.offender_events_ui_queue.sqs_name)                                     = module.offender_events_ui_queue.irsa_policy_arn,
    (module.offender_events_ui_dead_letter_queue.sqs_name)                         = module.offender_events_ui_dead_letter_queue.irsa_policy_arn,
    (module.pathfinder_offender_events_queue.sqs_name)                             = module.pathfinder_offender_events_queue.irsa_policy_arn,
    (module.pathfinder_probation_offender_events_queue.sqs_name)                   = module.pathfinder_probation_offender_events_queue.irsa_policy_arn,
    (module.pathfinder_offender_events_dead_letter_queue.sqs_name)                 = module.pathfinder_offender_events_dead_letter_queue.irsa_policy_arn,
    (module.pathfinder_probation_offender_events_dead_letter_queue.sqs_name)       = module.pathfinder_probation_offender_events_dead_letter_queue.irsa_policy_arn,
    (module.pic_probation_offender_events_queue.sqs_name)                          = module.pic_probation_offender_events_queue.irsa_policy_arn,
    (module.pic_probation_offender_events_dead_letter_queue.sqs_name)              = module.pic_probation_offender_events_dead_letter_queue.irsa_policy_arn,
    (module.prison_to_probation_update_queue.sqs_name)                             = module.prison_to_probation_update_queue.irsa_policy_arn,
    (module.prison_to_probation_update_dead_letter_queue.sqs_name)                 = module.prison_to_probation_update_dead_letter_queue.irsa_policy_arn,
    (module.prisoner_offender_events_queue.sqs_name)                               = module.prisoner_offender_events_queue.irsa_policy_arn,
    (module.prisoner_offender_events_dead_letter_queue.sqs_name)                   = module.prisoner_offender_events_dead_letter_queue.irsa_policy_arn,
    (module.prisoner_offender_search_queue.sqs_name)                               = module.prisoner_offender_search_queue.irsa_policy_arn,
    (module.prisoner_offender_search_dead_letter_queue.sqs_name)                   = module.prisoner_offender_search_dead_letter_queue.irsa_policy_arn,
    (module.whereabouts_api_queue.sqs_name)                                        = module.whereabouts_api_queue.irsa_policy_arn,
    (module.whereabouts_api_dead_letter_queue.sqs_name)                            = module.whereabouts_api_dead_letter_queue.irsa_policy_arn
  }

  sns_irsa_policies = {
    (module.offender_events.topic_name)             = module.offender_events.irsa_policy_arn,
    (module.probation_offender_events.topic_name)   = module.probation_offender_events.irsa_policy_arn,
    (module.offender_assessments_events.topic_name) = module.probation_offender_events.irsa_policy_arn
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