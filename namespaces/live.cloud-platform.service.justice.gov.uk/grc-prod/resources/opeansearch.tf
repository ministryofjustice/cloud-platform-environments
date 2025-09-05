module "opensearch_alert" {
    source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch-alert?ref=1.0.2" #use the latest version

    secret_name                    = "live-grc-prod-40a794929b6cb78d"
    secret_key                     = "OPENSEARCH_SLACK_URL"
    slack_channel_name             = "dts-legacy-apps-system-alerts"
    slack_channel_name_description = "DTS Legacy Services Production Alerts"
    opensearch_alert_name          = "grc-prod-bots"
    opensearch_alert_enabled       = true
    monitor_period_interval        = "30"
    monitor_period_unit            = "MINUTES"
    index                          = ["live_kubernetes_ingress-*"]

    trigger_name                   = "grc-prod-bots"
    serverity                      = "1"
    query_source                   = "ctx.results[0].hits.total.value > 5"
    action_name                    = "grc-prod-send-alert"
    slack_message_subject          = "GRC Prod Bot Alert"
    slack_message_template         = "GRC Prod Monitor {{ctx.monitor.name}} just entered alert status. Please investigate the issue.\n- Trigger: {{ctx.trigger.name}}\n- Severity: {{ctx.trigger.severity}}"
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
                          "log_processed.kubernetes_namespace": "grc-prod"
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

module "opensearch_dos_alert" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch-alert?ref=1.0.2" #use the latest version

  secret_name                    = "live-grc-prod-40a794929b6cb78d"
  secret_key                     = "OPENSEARCH_SLACK_URL"
  slack_channel_name             = "dts-legacy-apps-system-alerts"
  slack_channel_name_description = "DTS Legacy Services Production Alerts"
  opensearch_alert_name          = "grc-prod-dos"
  opensearch_alert_enabled       = true
  monitor_period_interval        = "60"
  monitor_period_unit            = "MINUTES"
  index                          = ["live_kubernetes_ingress-*"]

  trigger_name                   = "grc-prod-dos"
  serverity                      = "2"
  query_source                   = "ctx.results[0].aggregations.top_ips.buckets.stream().anyMatch(b -> b.doc_count > 150)"
  action_name                    = "grc-prod-send-alert"
  slack_message_subject          = "GRC Prod DOS Alert"
  slack_message_template         = "GRC Prod Monitor {{ctx.monitor.name}} just entered alert status for DoS. Please investigate the issue.\n- Trigger: {{ctx.trigger.name}}\n- Severity: {{ctx.trigger.severity}}\n- Top offending IPs:\n{{#ctx.results.0.aggregations.top_ips.buckets}}  IP: {{key}} - Count: {{doc_count}}\n{{/ctx.results.0.aggregations.top_ips.buckets}}"
  alert_throttle_enabled         = true
  throttle_value                 = 60
  throttle_unit                  = "MINUTES"
  environment_name               = var.environment
  alert_query = jsonencode(
    {
      "size": 20,
      "query": {
        "bool": {
          "must_not": [
            {"prefix": {"log_processed.request_uri.keyword": "/is-first-visit"}},
            {"prefix": {"log_processed.request_uri.keyword": "/personal-details"}},
            {"prefix": {"log_processed.request_uri.keyword": "/upload"}},
            {"prefix": {"log_processed.request_uri.keyword": "/check-documents"}},
            {"prefix": {"log_processed.request_uri.keyword": "/overseas-check"}},
            {"prefix": {"log_processed.request_uri.keyword": "/declaration"}},
            {"prefix": {"log_processed.request_uri.keyword": "/reference-number"}},
            {"prefix": {"log_processed.request_uri.keyword": "/security-code"}},
            {"prefix": {"log_processed.request_uri.keyword": "/submit-and-pay"}},
            {"prefix": {"log_processed.request_uri.keyword": "/task-list"}},
            {"prefix": {"log_processed.request_uri.keyword": "/birth-registration"}},
            {"prefix": {"log_processed.request_uri.keyword": "/partnership-details"}},
            {"prefix": {"log_processed.request_uri.keyword": "/medical-reports"}},
            {"prefix": {"log_processed.request_uri.keyword": "/gender-evidence"}},
            {"prefix": {"log_processed.request_uri.keyword": "/statutory-declarations"}},
            {"prefix": {"log_processed.request_uri.keyword": "/save-and-return"}},
            {"prefix": {"log_processed.request_uri.keyword": "/images"}},
            {"prefix": {"log_processed.request_uri.keyword": "/overseas-approved-check"}},
            {"prefix": {"log_processed.request_uri.keyword": "/applications"}},
            {"prefix": {"log_processed.request_uri.keyword": "/sign-in-with-security_code"}},
            {"prefix": {"log_processed.request_uri.keyword": "/glimr"}},
            {"prefix": {"log_processed.request_uri.keyword": "/set_language"}},
            {"prefix": {"log_processed.request_uri.keyword": "/privacy-policy"}},
            {"prefix": {"log_processed.request_uri.keyword": "/static"}},
            {"prefix": {"log_processed.request_uri.keyword": "/asset"}},
            {"prefix": {"log_processed.request_uri.keyword": "/css"}},
            {"prefix": {"log_processed.request_uri.keyword": "/favicon.ico"}},
            {"match":  {"log_processed.request_uri.keyword": {"query": "/"}}}
          ],
          "filter": [
            {
              "range": {
                "@timestamp": {
                  "gte": "now-60m",
                  "lte": "now"
                }
              }
            },
            {
              "bool": {
                "should": [
                  {
                    "match_phrase": {
                      "log_processed.kubernetes_namespace": "grc-prod"
                    }
                  }
                ],
                "minimum_should_match": 1
              }
            }
          ]
        }
      },
      "aggs": {
        "top_ips": {
          "terms": {
            "field": "log_processed.remote_addr.keyword",
            "size": 10
          }
        }
      }
    }
  )
}
