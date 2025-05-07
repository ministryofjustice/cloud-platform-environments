# This is to share secrets with integration api.

resource "kubernetes_secret" "integration-api-secret" {
  metadata {
    name      = "eawp-assessment-events-secret"
    namespace = "hmpps-integration-api-dev"
  }

  data = {
    sqs_queue_url  = module.eawp_assessment_events_queue.sqs_id
    sqs_queue_arn  = module.eawp_assessment_events_queue.sqs_arn
    sqs_queue_name = module.eawp_assessment_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "integration-api-dlq-secret" {
  metadata {
    name      = "eawp-assessment-events-dlq-secret"
    namespace = "hmpps-integration-api-dev"
  }

  data = {
    sqs_queue_url  = module.eawp_assessment_events_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.eawp_assessment_events_dead_letter_queue.sqs_arn
    sqs_queue_name = module.eawp_assessment_events_dead_letter_queue.sqs_name
  }
}