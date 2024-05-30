module "opensearch_alert" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch-alerts?ref=opensearch-alert-for-user-2"

  opensearch_alert_name    = "test alert"
  opensearch_alert_enabled = true
  monitor_period_interval  = 1
  monitor_period_unit      = "MINUTES"
  indices                  = ["live_kubernetes_cluster*"]
  query_source             = "ctx.results[0].hits.total.value > 1"
  trigger_id               = "test-test"
  trigger_name             = "test-test"
  action_id                = "test-test"
  action_name              = "test-test"
  slack_channel_id         = "test-test"
  slack_channel_name       = "test-test"
  slack_message_subject    = "test-test"
  message_template         = "Monitor {{ctx.monitor.name}} just entered alert status. Please investigate the issue.\n- Trigger: {{ctx.trigger.name}}\n- Severity: {{ctx.trigger.severity}}\n- Period start: {{ctx.periodStart}}\n- Period end: {{ctx.periodEnd}}"
  team_name                = var.team_name
  business_unit            = var.business_unit
  application              = var.application
  is_production            = var.is_production
  environment_name         = var.environment
  infrastructure_support   = var.infrastructure_support
  namespace                = var.namespace
  secret_id                = module.secret.secret_id
  query = jsonencode(
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