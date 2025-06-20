resource "notification_failed_alert" {
  name                = "${var.display_name} (${var.cloud_platform_environment}) - Manage-A-Workforce - Notification failed alert"
  data_source_id      = data.azurerm_log_analytics_workspace.workspace.id
  description         = "Alert when notifications to users are failing"
  enabled             = var.alerts_enabled
  location            = data.azurerm_log_analytics_workspace.workspace.location
  resource_group_name = var.alerts_rg

  query = <<-QUERY
    traces
    | where message contains "Failed to send notification and allocate"
    | summarize count()
  QUERY

  severity    = 1
  frequency   = 60
  time_window = 60

  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }

  action {
    action_group           = [var.action_group_id]
    custom_webhook_payload = <<EOT
      {
        "blocks": [
          {
            "type": "header",
            "text": {
              "type": "plain_text",
              "text": ":alert_slow: *${var.display_name} (${var.cloud_platform_environment}) - Manage-A-Workforce - Notification failed alert",
              "emoji": true
            }
          },
          {
            "type": "rich_text",
            "elements": [
              {
                "type": "rich_text_section",
                "elements": [
                  {
                    "type": "text",
                    "text": "Notifications from APoP to Notify may be failing, please check gov.notify and application insights"
                  }
                ]
              }
            ]
          },
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "View the difference with the application insights query:"
            },
            "accessory": {
              "type": "button",
              "text": {
                "type": "plain_text",
                "text": ":mag: View",
                "emoji": true
              },
              "value": "view_query",
              "url": "#linktosearchresults",
              "action_id": "button-action"
            }
          }
        ]
      }
    EOT
  }
  tags = local.tags
}