module "opensearch_alert_app_log" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch-alert?ref=1.0.2" # use the latest module

  secret_name                    = "live-laa-data-claims-api-uat-40b01d3ef57692f3" 
  secret_key                     = "slack-alert-webhook"

  slack_channel_name             = "laa-data-stewardship-payments-nonprod-alerts" 
  slack_channel_name_description = "LAA Data Claims Non-prod alerts"

  environment_name               = var.environment
  opensearch_alert_name          = "LAA Data Claims API - Suspicious SQL-like pattern - Alert"
  opensearch_alert_enabled       = true
  monitor_period_interval        = "1"
  monitor_period_unit            = "MINUTES"
  alert_query                    = jsonencode(
    {
        "size": 500,
        "query": {
            "bool": {
                "filter": [
                    {
                        "multi_match": {
                            "query": "Suspicious SQL",
                            "fields": [],
                            "type": "phrase",
                            "operator": "OR",
                            "slop": 0,
                            "prefix_length": 0,
                            "max_expansions": 50,
                            "lenient": true,
                            "zero_terms_query": "NONE",
                            "auto_generate_synonyms_phrase_query": true,
                            "fuzzy_transpositions": true,
                            "boost": 1
                        }
                    },
                    {
                        "match_phrase": {
                            "kubernetes.namespace_name": {
                                "query": "laa-data-claims-api-uat",
                                "slop": 0,
                                "zero_terms_query": "NONE",
                                "boost": 1
                            }
                        }
                    },
                    {
                        "range": {
                            "@timestamp": {
                                "from": "{{period_end}}||-10m",
                                "to": "{{period_end}}",
                                "include_lower": true,
                                "include_upper": true,
                                "format": "epoch_millis",
                                "boost": 1
                            }
                        }
                    }
                ],
                "adjust_pure_negative": true,
                "boost": 1
            }
        },
        "version": true,
        "_source": {
            "includes": [],
            "excludes": []
        },
        "stored_fields": "*",
        "docvalue_fields": [
            {
                "field": "@timestamp",
                "format": "date_time"
            },
            {
                "field": "kubernetes.annotations.kubectl_kubernetes_io/restartedAt",
                "format": "date_time"
            }
        ],
        "script_fields": {},
        "sort": [
            {
                "@timestamp": {
                    "order": "desc",
                    "unmapped_type": "boolean"
                }
            }
        ],
        "aggregations": {
            "2": {
                "date_histogram": {
                    "field": "@timestamp",
                    "time_zone": "Europe/London",
                    "fixed_interval": "30s",
                    "offset": 0,
                    "order": {
                        "_key": "asc"
                    },
                    "keyed": false,
                    "min_doc_count": 1
                }
            }
        },
        "highlight": {
            "pre_tags": [
                "@opensearch-dashboards-highlighted-field@"
            ],
            "post_tags": [
                "@/opensearch-dashboards-highlighted-field@"
            ],
            "fragment_size": 2147483647,
            "fields": {
                "*": {}
            }
        }
    }
  )
  trigger_name                   = "LAA Data Claims API - Suspicious SQL-like pattern - Trigger"
  serverity                      = "1"
  query_source                   = "ctx.results[0].hits.total.value > 1"
  action_name                    = "Suspicious SQL-like pattern detected - Action"
  slack_message_subject          = ":alert: Suspicious SQL-like pattern detected in LAA Data Claims API Uat :alert:"
  slack_message_template         = "Monitor {{ctx.monitor.name}} just entered alert status. Please investigate the issue.\n- Trigger: {{ctx.trigger.name}}\n- Severity: {{ctx.trigger.severity}}" 
  alert_throttle_enabled         = true
  throttle_value                 = 60
  throttle_unit                  = "MINUTES"
}