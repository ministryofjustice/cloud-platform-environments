resource "kubernetes_secret" "integration-api-secret" {
  metadata {
    # There is no staging env for hmpps-integration-api currently so writing a renamed secret to dev until there is one
    name      = "sqs-hmpps-prison-visits-write-events-staging-secret"
    namespace = "hmpps-integration-api-dev"
  }

  data = {
    sqs_queue_url  = module.hmpps_prison_visits_write_events_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prison_visits_write_events_queue.sqs_arn
    sqs_queue_name = module.hmpps_prison_visits_write_events_queue.sqs_name
  }
}