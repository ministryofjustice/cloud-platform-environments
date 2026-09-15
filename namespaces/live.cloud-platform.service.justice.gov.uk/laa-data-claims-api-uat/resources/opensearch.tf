module "opensearch_alert_app_log" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch-alert?ref=1.0.2" # use the latest module

  secret_name                    = "live-laa-data-claims-api-uat-40b01d3ef57692f3"
  secret_key                     = "slack-alert-webhook"

  slack_channel_name             = "laa-data-stewardship-payments-nonprod-alerts" 
  slack_channel_name_description = "LAA Data Claims non-prod alerts"

  environment_name               = var.environment
  opensearch_alert_name          = "laa-data-claims-api-uat-sql-alert"
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
                        "match_all": {}
                    },
                    {
                        "match_phrase": {
                            "kubernetes.namespace_name": "laa-data-claims-api-uat"
                        }
                    },
                    {
                        "match_phrase": {
                            "log": "Suspicious SQL"
                        }
                    },
                    {
                        "range": {
                            "@timestamp": {
                                "from": "{{period_end}}||-15m",
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
  trigger_name                   = "laa-data-claims-api-uat-sql-trigger"
  serverity                      = "1"
  query_source                   = "ctx.results[0].hits.total.value > 5"
  action_name                    = "laa-data-claims-api-uat-sql-action"
  slack_message_subject          = ":alert: Suspicious SQL-like pattern detected in *laa-data-claims-api-uat* :alert:"
  slack_message_template         = "Monitor {{ctx.monitor.name}} just entered alert status. Please investigate the issue.\n- *Trigger*: {{ctx.trigger.name}}\n- *Severity*: {{ctx.trigger.severity}}\n- *Dashboard*: https://app-logs.cloud-platform.service.justice.gov.uk/_dashboards/app/data-explorer/discover#?_a=(discover:(columns:!(log),isDirty:!t,sort:!()),metadata:(indexPattern:bb90f230-0d2e-11ef-bf63-53113938c53a,view:discover))&_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now-15m,to:now))&_q=(filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!f,index:bb90f230-0d2e-11ef-bf63-53113938c53a,key:kubernetes.namespace_name,negate:!f,params:(query:laa-data-claims-api-uat),type:phrase),query:(match_phrase:(kubernetes.namespace_name:laa-data-claims-api-uat))),('$state':(store:appState),meta:(alias:!n,disabled:!f,index:bb90f230-0d2e-11ef-bf63-53113938c53a,key:log,negate:!f,params:(query:'Suspicious%20SQL'),type:phrase),query:(match_phrase:(log:'Suspicious%20SQL')))),query:(language:kuery,query:''))"
  alert_throttle_enabled         = true
  throttle_value                 = 15
  throttle_unit                  = "MINUTES"
}