# This is to share secrets with integration api.

resource "kubernetes_secret" "integration-api-secret" {
  metadata {
    name      = "cp-course-completion-events-secret"
    namespace = "hmpps-integration-api-dev"
  }

  data = {
    sqs_queue_url  = module.course_completion_events_queue.sqs_id
    sqs_queue_arn  = module.course_completion_events_queue.sqs_arn
    sqs_queue_name = module.course_completion_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "integration-api-dlq-secret" {
  metadata {
    name      = "cp-course-completion-events-dlq-secret"
    namespace = "hmpps-integration-api-dev"
  }

  data = {
    sqs_queue_url  = module.course_completion_events_dlq.sqs_id
    sqs_queue_arn  = module.course_completion_events_dlq.sqs_arn
    sqs_queue_name = module.course_completion_events_dlq.sqs_name
  }
}