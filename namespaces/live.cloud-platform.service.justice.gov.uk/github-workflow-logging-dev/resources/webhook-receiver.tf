resource "kubernetes_secret" "webhook_receiver" {
  metadata {
    name      = "github-workflow-logging"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url         = module.log_events_queue.sqs_id
    github_webhook_secret = random_password.github_webhook_secret.result
  }

  type = "Opaque"
}

resource "random_password" "github_webhook_secret" {
  length  = 32
  special = true
}

output "webhook_url" {
  description = "URL for GitHub webhooks to POST to"
  value       = "https://github-wfl-webhook.apps.live.cloud-platform.service.justice.gov.uk/webhook"
}

output "github_webhook_secret" {
  description = "Secret to use when creating GitHub webhooks"
  value       = random_password.github_webhook_secret.result
  sensitive   = true
}

output "sqs_queue_url" {
  description = "SQS queue URL for webhook receiver to publish to"
  value       = module.log_events_queue.sqs_id
}
