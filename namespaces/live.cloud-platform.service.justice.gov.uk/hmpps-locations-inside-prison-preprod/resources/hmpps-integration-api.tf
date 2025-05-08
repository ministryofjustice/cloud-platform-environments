mesource "kubernetes_secret" "integration-api-secret" {
  metadata {
    name      = "sqs-hmpps-update-from-external-system-events-queue-secret"
    namespace = "hmpps-integration-api-preprod"
  }

  data = {
    sqs_queue_url  = module.hmpps_update_from_external_system_events_queue.sqs_id
    sqs_queue_arn  = module.hmpps_update_from_external_system_events_queue.sqs_arn
    sqs_queue_name = module.hmpps_update_from_external_system_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "integration-api-dlq-secret" {
  metadata {
    name      = "sqs-hmpps-update-from-external-system-events-dlq-secret"
    namespace = "hmpps-integration-api-preprod"
  }

  data = {
    sqs_queue_url  = module.hmpps_update_from_external_system_events_dlq.sqs_id
    sqs_queue_arn  = module.hmpps_update_from_external_system_events_dlq.sqs_arn
    sqs_queue_name = module.hmpps_update_from_external_system_events_dlq.sqs_name
  }
}