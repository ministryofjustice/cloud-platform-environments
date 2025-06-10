module "opensearch_alert" {
    source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch-alert?ref=1.0.2" #use the latest version

    aws_opensearch_domain          = "cp-live-modsec-audit"   # required for modsec opensearch cluster
    aws_iam_role                   = "opensearch-access-role" # required for modsec opensearch cluster
    index                          = ["live_k8s_modsec*", "live_k8s_modsec_ingress*"] # required for modsec opensearch cluster
    secret_name                    = "live-civil-appeal-case-tracker-preprod-cd48a1d8f6100258"
    secret_key                     = "OPENSEARCH_SLACK_URL"
    environment_name               = var.environment
    slack_channel_name             = "dts-legacy-apps-system-alerts"
    slack_channel_name_description = "DTS Legacy Services Production Alerts"
    opensearch_alert_name          = "case-tracker-preprod-bots"
    opensearch_alert_enabled       = true
    monitor_period_interval        = "30"
    monitor_period_unit            = "MINUTES"
    alert_query = jsonencode(
      {
        query = {
          bool = {
            must = [],
            filter = [
            {
              match_all = {}
            },
            {
              bool = {
                minimum_should_match = 1,
                should = [
                  {
                    match_phrase = {
                      log_processed.kubernetes_namespace = "civil-appeal-case-tracker-preprod"
                    }
                  }
                ]
              }
            },
            {
              bool = {
                minimum_should_match = 1
                should = [
                  {
                    match_phrase = {
                      log_processed.http_user_agent = "bot"
                    }
                  }
                ],
              }
            },
            {
              range = {
                "@timestamp" = {
                  from = "{{period_end}}||-720m",
                  to = "{{period_end}}",
                  include_lower = true,
                  include_upper = true,
                  format = "epoch_millis",
                  boost = 1
                }
              }
            }
            ],
            should = [],
            must_not = []
          }
        }
      }
    )
    trigger_name                   = "case-tracker-preprod-bots"
    serverity                      = "1"
    query_source                   = "ctx.results[0].hits.total.value > 5"
    action_name                    = "case-tracker-preprod-send-alert"
    slack_message_subject          = "Case Tracker Pre-prod Bot Alert"
    slack_message_template         = "Monitor {{ctx.monitor.name}} just entered alert status. Please investigate the issue.\n- Trigger: {{ctx.trigger.name}}\n- Severity: {{ctx.trigger.severity}}"
    alert_throttle_enabled         = true
    throttle_value                 = 60
    throttle_unit                  = "MINUTES"
  }