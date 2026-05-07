resource "kubernetes_secret" "slack_webhook_nonprod" {
  count = var.slack_webhook_url_nonprod != "" ? 1 : 0

  metadata {
    name      = "slack-webhook-secret-nonprod"
    namespace = var.namespace
  }

  data = {
    webhook_url = var.slack_webhook_url_nonprod
  }
}

resource "kubernetes_manifest" "alertmanager_config_nonprod" {
  count = var.slack_webhook_url_nonprod != "" ? 1 : 0

  manifest = {
    apiVersion = "monitoring.coreos.com/v1alpha1"
    kind       = "AlertmanagerConfig"
    metadata = {
      name      = "hmpps-accredited-programmes-manage-and-deliver-alerts-nonprod"
      namespace = var.namespace
    }
    spec = {
      route = {
        receiver = "slack-nonprod"
        matchers = [
          {
            name  = "severity"
            value = "hmpps-accredited-programmes-manage-and-deliver-alerts-nonprod"
          }
        ]
      }
      receivers = [
        {
          name = "slack-nonprod"
          slackConfigs = [
            {
              apiURL = {
                name = kubernetes_secret.slack_webhook_nonprod[0].metadata[0].name
                key  = "webhook_url"
              }
              channel  = "#accredited-programmes-manage-and-deliver-alerts-nonprod"
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
