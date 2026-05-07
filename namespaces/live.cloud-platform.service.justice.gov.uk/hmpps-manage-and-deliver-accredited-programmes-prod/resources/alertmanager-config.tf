resource "kubernetes_secret" "slack_webhook_prod" {
  count = var.slack_webhook_url_prod != "" ? 1 : 0

  metadata {
    name      = "slack-webhook-secret-prod"
    namespace = var.namespace
  }

  data = {
    webhook_url = var.slack_webhook_url_prod
  }
}

resource "kubernetes_manifest" "alertmanager_config_prod" {
  count = var.slack_webhook_url_prod != "" ? 1 : 0

  manifest = {
    apiVersion = "monitoring.coreos.com/v1alpha1"
    kind       = "AlertmanagerConfig"
    metadata = {
      name      = "hmpps-accredited-programmes-manage-and-deliver-alerts-prod"
      namespace = var.namespace
    }
    spec = {
      route = {
        receiver = "slack-prod"
        matchers = [
          {
            name  = "severity"
            value = "hmpps-accredited-programmes-manage-and-deliver-alerts-prod"
          }
        ]
      }
      receivers = [
        {
          name = "slack-prod"
          slackConfigs = [
            {
              apiURL = {
                name = kubernetes_secret.slack_webhook_prod[0].metadata[0].name
                key  = "webhook_url"
              }
              channel  = "#accredited-programmes-manage-and-deliver-alerts-prod"
              sendResolved = true
              title    = "{{ .GroupLabels.alertname }}"
              text     = "{{ range .Alerts }}{{ .Annotations.message }}{{ end }}"
            }
          ]
        }
      ]
    }
  }
}
