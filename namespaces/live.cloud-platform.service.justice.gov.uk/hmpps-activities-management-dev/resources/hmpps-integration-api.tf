resource "kubernetes_secret" "integration-api-secret" {
  metadata {
    name      = "sqs-update-from-external-system-events-activities-queue-secret"
    namespace = "hmpps-integration-api-dev"
  }

  data = {
    sqs_queue_url  = module.update_from_external_system_events_queue.sqs_id
    sqs_queue_arn  = module.update_from_external_system_events_queue.sqs_arn
    sqs_queue_name = module.update_from_external_system_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "integration-api-dlq-secret" {
  metadata {
    name      = "sqs-update-from-external-system-events-activities-dlq-secret"
    namespace = "hmpps-integration-api-dev"
  }

  data = {
    sqs_queue_url  = module.update_from_external_system_events_dlq.sqs_id
    sqs_queue_arn  = module.update_from_external_system_events_dlq.sqs_arn
    sqs_queue_name = module.update_from_external_system_events_dlq.sqs_name
  }
}