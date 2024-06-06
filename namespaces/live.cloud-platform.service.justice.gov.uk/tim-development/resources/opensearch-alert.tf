module "opensearch_alert_1" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch-alerts?ref=os-alert-module"

  secret_name                    = "live-tim-development-014c5454b9aca2da"
  secret_key                     = "url"
  slack_channel_name             = "test-1"
  slack_channel_name_description = "slack-channel-description"
  opensearch_alert_name          = "test-1"
  opensearch_alert_enabled       = true
  monitor_period_interval        = "1"
  monitor_period_unit            = "MINUTES"

  trigger_name                   = "test-1"
  serverity                      = "1"
  query_source                   = "ctx.results[0].hits.total.value > 1"
  action_name                    = "test-1"
  slack_message_subject          = "slack-message-subject"
  slack_message_template         = "Monitor {{ctx.monitor.name}} just entered alert status. Please investigate the issue.\n- Trigger: {{ctx.trigger.name}}\n- Severity: {{ctx.trigger.severity}}" 
  alert_throttle_enabled         = true
  throttle_value                 = 60
  throttle_unit                  = "MINUTES"

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
      }
    }
  )
}