module "opensearch_alert_modsec" {
    source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch-alert?ref=1.0.2"

    aws_opensearch_domain          = "cp-live-modsec-audit"
    aws_iam_role                   = "opensearch-access-role"
    index                          = ["live_k8s_modsec*", "live_k8s_modsec_ingress*"]
    secret_name                    = "live-workforce-management-prod-f4d60e913c7079de"
    secret_key                     = "workforce-management-prod-slack"
    environment_name               = var.environment
    slack_channel_name             = "manage_a_workforce_live"
    slack_channel_name_description = "live alerts for maw service"
    opensearch_alert_name          = "allocations 406 errors"
    opensearch_alert_enabled       = true
    monitor_period_interval        = "12"
    monitor_period_unit            = "HOURS"
    alert_query = jsonencode(
      {
        query = {
          bool = {
            must = [],
            filter = [
              {
                bool = {
                  filter = [
                    {
                      multi_match = {
                        type = "phrase",
                        query = "workforce-management.hmpps.service.justice.gov.uk",
                        lenient = true
                      }
                    },
                    {
                      multi_match = {
                        type = "phrase",
                        query = "406",
                        lenient = true
                      }
                    }
                  ]
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
    trigger_name                   = "406 errors"
    serverity                       = "1"
    query_source                   = "ctx.results[0].hits.total.value > 1"
    action_name                    = "trigger-action-name"
    slack_message_subject          = "slack-message-subject"
    slack_message_template         = "Monitor {{ctx.monitor.name}} just entered alert status. Please investigate the issue.\n- Trigger: {{ctx.trigger.name}}\n- Severity: {{ctx.trigger.severity}}"
    alert_throttle_enabled         = true
    throttle_value                 = 60
    throttle_unit                  = "MINUTES"
  }