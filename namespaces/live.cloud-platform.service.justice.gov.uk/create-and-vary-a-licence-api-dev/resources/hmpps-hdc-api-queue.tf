# The hmpps_hdc_api_queue and its dead letter queue are owned by the licences-dev namespace,
# irsa.tf only imports the irsa policy arns; the app also needs the queue url/arn as a secret.
data "aws_sqs_queue" "hmpps_hdc_api_queue" {
  name = "create-and-vary-a-licence-devs-dev-hmpps_hdc_api_queue"
}

data "aws_sqs_queue" "hmpps_hdc_api_dead_letter_queue" {
  name = "create-and-vary-a-licence-devs-dev-hmpps_hdc_api_dlq"
}

resource "kubernetes_secret" "hmpps_hdc_api_queue" {
  metadata {
    name      = "sqs-hdc-cvl-events-queue-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = data.aws_sqs_queue.hmpps_hdc_api_queue.url
    sqs_queue_arn  = data.aws_sqs_queue.hmpps_hdc_api_queue.arn
    sqs_queue_name = "hmpps_hdc_api_queue"
  }
}

resource "kubernetes_secret" "hmpps_hdc_api_dead_letter_queue" {
  metadata {
    name      = "sqs-hdc-cvl-events-dlq-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = data.aws_sqs_queue.hmpps_hdc_api_dead_letter_queue.url
    sqs_queue_arn  = data.aws_sqs_queue.hmpps_hdc_api_dead_letter_queue.arn
    sqs_queue_name = "hmpps_hdc_api_dlq"
  }
}
