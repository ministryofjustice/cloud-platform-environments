module "opensearch_alert" {
    source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch-alert?ref=1.0.2"

    secret_name                    = "live-laa-cla-backend-production-534b062abc2393c7"
    secret_key                     = "url"
    environment_name               = var.environment-name
    slack_channel_name             = "cala-alerts"
    slack_channel_name_description = "cala-alerts"
    opensearch_alert_name          = "Cla Backend rate limit alerts"
    opensearch_alert_enabled       = true
    monitor_period_interval        = "60"
    monitor_period_unit            = "MINUTES"
    alert_query                    = jsonencode(
      {
          "sort": [
            {
              "@timestamp": {
                "order": "desc",
                "unmapped_type": "boolean"
              }
            }
          ],
          "size": 5000,
          "version": true,
          "aggs": {
            "2": {
              "date_histogram": {
                "field": "@timestamp",
                "calendar_interval": "1m",
                "time_zone": "Europe/London",
                "min_doc_count": 1
              }
            }
          },
          "stored_fields": [
            "*"
          ],
          "script_fields": {},
          "docvalue_fields": [
            {
              "field": "@timestamp",
              "format": "date_time"
            },
            {
              "field": "kubernetes.annotations.kubectl_kubernetes_io/restartedAt",
              "format": "date_time"
            },
            {
              "field": "log_processed.time",
              "format": "date_time"
            }
          ],
          "_source": {
            "excludes": []
          },
          "query": {
            "bool": {
              "must": [],
              "filter": [
                {
                  "multi_match": {
                    "type": "phrase",
                    "query": "\"status\": 429",
                    "lenient": true
                  }
                },
                {
                  "match_phrase": {
                    "log_processed.kubernetes_namespace": "laa-cla-backend-production"
                  }
                },
                {
                  "range": {
                    "@timestamp": {
                      "gte": "now-60",
                      "lte": "now",
                    }
                  }
                }
              ],
              "should": [],
              "must_not": []
            }
          },
          "highlight": {
            "pre_tags": [
              "@opensearch-dashboards-highlighted-field@"
            ],
            "post_tags": [
              "@/opensearch-dashboards-highlighted-field@"
            ],
            "fields": {
              "*": {}
            },
            "fragment_size": 2147483647
          }
      }
    )
    trigger_name                   = "cla-backend-rate-limit"
    serverity                      = "1"
    query_source                   = "ctx.results[0].hits.total.value > 1"
    action_name                    = "send-alert"
    slack_message_subject          = "Cla Backend rate limit threshold surpassed"
    slack_message_template         = "Monitor {{ctx.monitor.name}} just entered alert status. Please investigate the issue.\n- Trigger: {{ctx.trigger.name}}\n- Severity: {{ctx.trigger.severity}}"
    alert_throttle_enabled         = true
    throttle_value                 = 60
    throttle_unit                  = "MINUTES"
  }