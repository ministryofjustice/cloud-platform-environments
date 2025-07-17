module "opensearch_alert" {
    source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch-alert?ref=1.0.2" #use the latest version

    secret_name                    = "live-certificated-bailiffs-prod-c31d0037fef87908"
    secret_key                     = "OPENSEARCH_SLACK_URL"
    slack_channel_name             = "dts-legacy-apps-system-alerts"
    slack_channel_name_description = "DTS Legacy Service Production Alerts"
    opensearch_alert_name          = "certificated-bailiffs-prod-bots"
    opensearch_alert_enabled       = true
    monitor_period_interval        = "30"
    monitor_period_unit            = "MINUTES"
    index                          = ["live_kubernetes_ingress-*"]

    trigger_name                   = "certificated-bailiffs-prod-bots"
    serverity                      = "1"
    query_source                   = "ctx.results[0].hits.total.value > 10"
    action_name                    = "certificated-bailiffs-prod-send-alert"
    slack_message_subject          = "Certificated Bailiffs Prod Bot Alert"
    slack_message_template         = "Monitor {{ctx.monitor.name}} just entered alert status. Please investigate the issue.\n- Trigger: {{ctx.trigger.name}}\n- Severity: {{ctx.trigger.severity}}"
    alert_throttle_enabled         = true
    throttle_value                 = 60
    throttle_unit                  = "MINUTES"
    environment_name               = var.environment
    alert_query = jsonencode(
      {
         "size": 20,
         "query": {
            "bool": {
              "must": [],
              "filter": [
                {
                  "match_all": {}
                },
                {
                  "bool": {
                    "should": [
                      {
                        "match_phrase": {
                          "log_processed.kubernetes_namespace": "certificated-bailiffs-prod"
                        }
                      }
                    ],
                    "minimum_should_match": 1
                  }
                },
                {
                  "bool": {
                    "should": [
                      {
                        "match_phrase": {
                          "log_processed.http_user_agent": "bot"
                        }
                      }
                    ],
                    "minimum_should_match": 1
                  }
                },
                {
                  "range": {
                    "@timestamp": {
                    "from": "{{period_end}}||-30m",
                    "to": "{{period_end}}",
                    "include_lower": true,
                    "include_upper": true,
                    "format": "epoch_millis",
                    "boost": 1
                    }
                  }
                }
              ],
              "should": [],
              "must_not": []
            }
        }
    }
    )
  }
