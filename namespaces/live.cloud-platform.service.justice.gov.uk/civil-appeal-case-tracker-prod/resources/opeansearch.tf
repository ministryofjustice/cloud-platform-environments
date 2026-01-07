module "opensearch_alert" {
    source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch-alert?ref=1.0.2" #use the latest version

    secret_name                    = "live-civil-appeal-case-tracker-prod-9b11d3c77b56564c"
    secret_key                     = "OPENSEARCH_SLACK_URL"
    slack_channel_name             = "dts-legacy-apps-system-alerts"
    slack_channel_name_description = "DTS Legacy Services Production Alerts"
    opensearch_alert_name          = "case-tracker-prod-bots"
    opensearch_alert_enabled       = true
    monitor_period_interval        = "30"
    monitor_period_unit            = "MINUTES"
    index                          = ["live_kubernetes_ingress-*"]

    trigger_name                   = "case-tracker-prod-bots"
    serverity                      = 1
    query_source                   = "ctx.results[0].aggregations.top_user_agents.buckets.stream().anyMatch(b -> b.doc_count > 50)"
    action_name                    = "case-tracker-prod-send-alert"
    slack_message_subject          = "Case Tracker Prod Bot Alert"
    slack_message_template         = "Monitor {{ctx.monitor.name}} just entered alert status. Please investigate the issue.\n- Trigger: {{ctx.trigger.name}}\n- Severity: {{ctx.trigger.severity}}\n- Top bot agents:\n{{#ctx.results.0.aggregations.top_user_agents.buckets}}  Agent: {{key}} - Count: {{doc_count}}\n{{/ctx.results.0.aggregations.top_user_agents.buckets}}"
    alert_throttle_enabled         = true
    throttle_value                 = 60
    throttle_unit                  = "MINUTES"
    environment_name               = var.environment
    alert_query = jsonencode({
    "size": 0,
    "query": {
      "bool": {
        "filter": [
          {
            "bool": {
              "should": [
                {
                  "wildcard": {
                    "log_processed.http_user_agent": {
                      "value": "*bot*",
                      "case_insensitive": true
                    }
                  }
                },
                {
                  "wildcard": {
                    "log_processed.http_user_agent": {
                      "value": "*crawler*",
                      "case_insensitive": true
                    }
                  }
                },
                {
                  "wildcard": {
                    "log_processed.http_user_agent": {
                      "value": "*spider*",
                      "case_insensitive": true
                    }
                  }
                },
                {
                  "wildcard": {
                    "log_processed.http_user_agent": {
                      "value": "*robot*",
                      "case_insensitive": true
                    }
                  }
                },
                {
                  "wildcard": {
                    "log_processed.http_user_agent": {
                      "value": "*crawl*",
                      "case_insensitive": true
                    }
                  }
                }
              ],
              "minimum_should_match": 1
            }
          },
          {
            "match_phrase": {
              "log_processed.kubernetes_namespace": "civil-appeal-case-tracker-prod"
            }
          },
          {
            "range": {
              "@timestamp": {
                "from": "{{period_end}}||-30m",
                "to": "{{period_end}}",
                "format": "epoch_millis"
              }
            }
          }
        ],
        "must_not": [
          {
              "wildcard": {
                  "log_processed.http_user_agent": {
                      "value": "*pingdom*",
                      "case_insensitive": true
                  }
              }
          }
        ]
      }
    },
    "aggs": {
      "top_user_agents": {
        "terms": {
          "field": "log_processed.http_user_agent.keyword",
          "size": 10
        }
      }
    }
  })
  }

    module "opensearch_dos_alert" {
    source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch-alert?ref=1.0.2" #use the latest version

    secret_name                    = "live-civil-appeal-case-tracker-prod-9b11d3c77b56564c"
    secret_key                     = "OPENSEARCH_SLACK_URL"
    slack_channel_name             = "dts-legacy-apps-system-alerts"
    slack_channel_name_description = "DTS Legacy Services Production Alerts"
    opensearch_alert_name          = "case-tracker-prod-dos"
    opensearch_alert_enabled       = true
    monitor_period_interval        = "60"
    monitor_period_unit            = "MINUTES"
    index                          = ["live_kubernetes_ingress-*"]
    trigger_name                   = "case-tracker-prod-dos"
    serverity                      = "2"
    query_source                   = "ctx.results[0].aggregations.top_ips.buckets.stream().anyMatch(b -> b.doc_count > 300)"
    action_name                    = "case-tracker-prod-send-alert"
    slack_message_subject          = "Case Tracker Prod Dos Alert"
    alert_throttle_enabled         = true
    throttle_value                 = 60
    throttle_unit                  = "MINUTES"
    environment_name               = var.environment
    slack_message_template         = "Monitor {{ctx.monitor.name}} just entered alert status for DoS. Please investigate the issue.\n- Trigger: {{ctx.trigger.name}}\n- Severity: {{ctx.trigger.severity}}\n- Top offending IPs:\n{{#ctx.results.0.aggregations.top_ips.buckets}}  IP: {{key}} - Count: {{doc_count}}\n{{/ctx.results.0.aggregations.top_ips.buckets}}"
                                      
    alert_query = jsonencode(
      {
        "size": 20,
        "query": {
          "bool": {
            "must_not": [
              { "prefix": { "log_processed.request_uri.keyword": "/images" } },
              { "prefix": { "log_processed.request_uri.keyword": "/js" } },
              { "prefix": { "log_processed.request_uri.keyword": "/dg_scripts" } },
              { "prefix": { "log_processed.request_uri.keyword": "/asset" } },
              { "prefix": { "log_processed.request_uri.keyword": "/favicon.ico" } },
              { "prefix": { "log_processed.request_uri.keyword": "/css" } },
              { "prefix": { "log_processed.request_uri.keyword": "/search.jsp" } },
              { "prefix": { "log_processed.request_uri.keyword": "/search.do" } },
              { "prefix": { "log_processed.request_uri.keyword": "/getDetail.do" } },
              { "match": { "log_processed.request_uri.keyword": { "query": "/" } } }
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
                          "log_processed.kubernetes_namespace": "civil-appeal-case-tracker-prod"
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
  