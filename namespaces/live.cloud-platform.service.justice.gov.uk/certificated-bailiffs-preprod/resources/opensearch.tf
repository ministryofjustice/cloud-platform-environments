module "opensearch_alert" {
    source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch-alert?ref=1.0.2" #use the latest version

    secret_name                    = "live-certificated-bailiffs-preprod-a2bfb8b5b867cbf6"
    secret_key                     = "OPENSEARCH_SLACK_URL"
    slack_channel_name             = "dts-legacy-apps-system-alerts"
    slack_channel_name_description = "DTS Legacy Service Pre-Production Alerts"
    opensearch_alert_name          = "certificated-bailiffs-preprod-bots"
    opensearch_alert_enabled       = true
    monitor_period_interval        = "30"
    monitor_period_unit            = "MINUTES"
    index                          = ["live_kubernetes_ingress-*"]

    trigger_name                   = "certificated-bailiffs-preprod-bots"
    serverity                      = "1"
    query_source                   = "ctx.results[0].hits.total.value > 15"
    action_name                    = "certificated-bailiffs-preprod-send-alert"
    slack_message_subject          = "Certificated Bailiffs Pre-prod Bot Alert"
    slack_message_template         = "Monitor {{ctx.monitor.name}} just entered alert status. Please investigate the issue.\n- Trigger: {{ctx.trigger.name}}\n- Severity: {{ctx.trigger.severity}}\n- Top bot agents:\n{{#ctx.results.0.aggregations.top_user_agents.buckets}} Agent: {{key}} - Count: {{doc_count}}\n{{/ctx.results.0.aggregations.top_user_agents.buckets}}"
    alert_throttle_enabled         = true
    throttle_value                 = 60
    throttle_unit                  = "MINUTES"
    environment_name               = var.environment
    alert_query = jsonencode(
      {
         "size": 0,
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
                          "log_processed.kubernetes_namespace": "certificated-bailiffs-preprod"
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
        }
    }
    )
  }
  

module "opensearch_dos_alert" {
    source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch-alert?ref=1.0.2" #use the latest version

    secret_name                    = "live-certificated-bailiffs-preprod-a2bfb8b5b867cbf6"
    secret_key                     = "OPENSEARCH_SLACK_URL"
    slack_channel_name             = "dts-legacy-apps-system-alerts"
    slack_channel_name_description = "DTS Legacy Service Pre-Production Alerts"
    opensearch_alert_name          = "certificated-bailiffs-preprod-dos"
    opensearch_alert_enabled       = true
    monitor_period_interval        = "60"
    monitor_period_unit            = "MINUTES"
    index                          = ["live_kubernetes_ingress-*"]
    trigger_name                   = "certificated-bailiffs-preprod-dos"
    serverity                      = "2"
    query_source                   = "ctx.results[0].aggregations.top_ips.buckets.stream().anyMatch(b -> b.doc_count > 25)"
    action_name                    = "certificated-bailiffs-preprod-send-alert"
    slack_message_subject          = "Certificated Bailiffs Pre-prod DoS Alert"
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
              { "prefix": { "log_processed.request_uri.keyword": "/ords" } },
              { "prefix": { "log_processed.request_uri.keyword": "/css" } },
              { "prefix": { "log_processed.request_uri.keyword": "/favicon.ico" } },
              { "prefix": { "log_processed.request_uri.keyword": "/searchPublic.do" } },
              { "prefix": { "log_processed.request_uri.keyword": "/newsearchPublic.do" } },
              { "prefix": { "log_processed.request_uri.keyword": "/CertificatedBailiffs/" } },
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
                          "log_processed.kubernetes_namespace": "certificated-bailiffs-preprod"
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
  