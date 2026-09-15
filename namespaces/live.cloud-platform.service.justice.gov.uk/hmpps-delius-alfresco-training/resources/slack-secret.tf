resource "kubernetes_secret" "slack_alert_webhook_secret" {
  metadata {
    name      = "slack-alert-webhook-secret"
    namespace = var.namespace
  }
}
