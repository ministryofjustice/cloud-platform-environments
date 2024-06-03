module "opensearch_alert_1" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch-alerts?ref=update-secret-setting"

  opensearch_alert_name    = "test-2"
  opensearch_alert_enabled = true
  monitor_period_interval  = 1
  monitor_period_unit      = "MINUTES"
  indices                  = ["live_kubernetes_cluster*"]
  query_source             = "ctx.results[0].hits.total.value > 1"
  trigger_name             = "test"
  action_name              = "test"
  slack_channel_name       = "test"
  slack_message_subject    = "test"
  slack_message_template   = "Monitor {{ctx.monitor.name}} just entered alert status. Please investigate the issue.\n- Trigger: {{ctx.trigger.name}}\n- Severity: {{ctx.trigger.severity}}\n- Period start: {{ctx.periodStart}}\n- Period end: {{ctx.periodEnd}}"
  secret_key               = "url"
  serverity                = 1
  secret_id                = "live-tim-development-014c5454b9aca2da"
  alert_query = jsonencode(
    {
      "size" : 0,
      "query" : {
        "bool" : {
          "filter" : [
            {
              "bool" : {
                "filter" : [
                  {
                    "bool" : {
                      "should" : [
                        {
                          "match_phrase" : {
                            "kubernetes.namespace_name" : {
                              "query" : "kube-system",
                              "slop" : 0,
                              "zero_terms_query" : "NONE",
                              "boost" : 1
                            }
                          }
                        }
                      ],
                      "adjust_pure_negative" : true,
                      "minimum_should_match" : "1",
                      "boost" : 1
                    }
                  },
                  {
                    "bool" : {
                      "filter" : [
                        {
                          "bool" : {
                            "should" : [
                              {
                                "match_phrase" : {
                                  "kubernetes.pod_name" : {
                                    "query" : "external-dns-*",
                                    "slop" : 0,
                                    "zero_terms_query" : "NONE",
                                    "boost" : 1
                                  }
                                }
                              }
                            ],
                            "adjust_pure_negative" : true,
                            "minimum_should_match" : "1",
                            "boost" : 1
                          }
                        },
                        {
                          "bool" : {
                            "filter" : [
                              {
                                "bool" : {
                                  "should" : [
                                    {
                                      "match_phrase" : {
                                        "log" : {
                                          "query" : "level=error",
                                          "slop" : 0,
                                          "zero_terms_query" : "NONE",
                                          "boost" : 1
                                        }
                                      }
                                    }
                                  ],
                                  "adjust_pure_negative" : true,
                                  "minimum_should_match" : "1",
                                  "boost" : 1
                                }
                              },
                              {
                                "bool" : {
                                  "should" : [
                                    {
                                      "match_phrase" : {
                                        "log" : {
                                          "query" : "Throttling: Rate exceeded",
                                          "slop" : 0,
                                          "zero_terms_query" : "NONE",
                                          "boost" : 1
                                        }
                                      }
                                    }
                                  ],
                                  "adjust_pure_negative" : true,
                                  "minimum_should_match" : "1",
                                  "boost" : 1
                                }
                              }
                            ],
                            "adjust_pure_negative" : true,
                            "boost" : 1
                          }
                        }
                      ],
                      "adjust_pure_negative" : true,
                      "boost" : 1
                    }
                  }
                ],
                "adjust_pure_negative" : true,
                "boost" : 1
              }
            },
            {
              "range" : {
                "@timestamp" : {
                  "from" : "{{period_end}}||-1m",
                  "to" : "{{period_end}}",
                  "include_lower" : true,
                  "include_upper" : true,
                  "format" : "epoch_millis",
                  "boost" : 1
                }
              }
            }
          ],
          "adjust_pure_negative" : true,
          "boost" : 1
        }
      },
      "aggregations" : {}
    }
  )
}