module "opensearch_alert" {
    source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch-alerts?ref=1.0.0" #use the latest version

    secret_name                    = "live-laa-inquests-internal-ui-prod-1c7c229b26e1dd53"
    secret_key                     = "url"
    environment_name               = var.environment
    slack_channel_name             = "laa-inquests-prod-alerts"
    slack_channel_name_description = "Channel for laa inquests production alerts "
    opensearch_alert_name          = "laa-inquests-internal-ui-prod-alert"
    opensearch_alert_enabled       = true
    monitor_period_interval        = "15"
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
        "size": 500,
        "version": true,
        "aggs": {
            "2": {
            "date_histogram": {
                "field": "@timestamp",
                "fixed_interval": "1m",
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
                "bool": {
                    "filter": [
                    {
                        "bool": {
                        "should": [
                            {
                            "match_phrase": {
                                "kubernetes.namespace_name": "laa-inquests-internal-ui-prod"
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
                            "bool": {
                                "should": [
                                {
                                    "match_phrase": {
                                    "log": "level error"
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
                                    "query_string": {
                                    "fields": [
                                        "log.keyword"
                                    ],
                                    "query": "ERROR*"
                                    }
                                }
                                ],
                                "minimum_should_match": 1
                            }
                            }
                        ],
                        "minimum_should_match": 1
                        }
                    }
                    ]
                }
                },
                {
                "range": {
                    "@timestamp": {
                        "from": "{{period_end}}||-15m",
                        "to": "{{period_end}}",
                        "format": "epoch_millis"
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
    trigger_name                   = "laa-inquests-internal-ui-prod-errors-detected"
    serverity                      = "1"
    query_source                   = "ctx.results[0].hits.total.value > 1"
    action_name                    = "laa-inquests-internal-ui-prod-action"
    slack_message_subject          = ":alert: Errors detected in laa-iqnuests-internal-ui-prod application :alert:"
    slack_message_template         = "Monitor {{ctx.monitor.name}} just entered alert status. Please investigate the issue.\n- Trigger: {{ctx.trigger.name}}\n- Severity: {{ctx.trigger.severity}}" 
    alert_throttle_enabled         = true
    throttle_value                 = 60
    throttle_unit                  = "MINUTES"
  }