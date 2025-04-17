resource "kubernetes_secret" "integration-api-secret" {
  metadata {
    name      = "sqs-hmpps-prison-visits-write-events-secret"
    namespace = "hmpps-integration-api-preprod"
  }

  data = {
    sqs_queue_url  = module.hmpps_prison_visits_write_events_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prison_visits_write_events_queue.sqs_arn
    sqs_queue_name = module.hmpps_prison_visits_write_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "integration-api-dlq-secret" {
  metadata {
    name      = "sqs-hmpps-prison-visits-write-events-dlq-secret"
    namespace = "hmpps-integration-api-preprod"
  }

  data = {
    sqs_queue_url  = module.hmpps_prison_visits_write_events_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prison_visits_write_events_dead_letter_queue.sqs_arn
    sqs_queue_name = module.hmpps_prison_visits_write_events_dead_letter_queue.sqs_name
  }
}