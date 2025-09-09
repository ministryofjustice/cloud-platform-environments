module "opensearch_alert_ip_prefix" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch-alert?ref=1.0.2"

  secret_name                    = "live-monitoring-3ca3cc4085f66db3"
  secret_key                     = "url"
  slack_channel_name             = "high-priority-alarms"
  slack_channel_name_description = "Cloud Platform high priority alarms channel"
  opensearch_alert_name          = "Unable to assign IP prefix monitor - InsufficientCidrBlocks alert"
  opensearch_alert_enabled       = true
  monitor_period_interval        = "1"
  monitor_period_unit            = "MINUTES"
  index                          = ["live_ipamd-*"]

  trigger_name           = "Unable to assign IP prefix monitor - InsufficientCidrBlocks trigger"
  serverity              = 1
  query_source           = "ctx.results[0].hits.total.value > 0"
  action_name            = "Unable to assign IP prefix monitor - InsufficientCidrBlocks action"
  slack_message_subject  = ":alert: Unable to assign IP prefix monitor - InsufficientCidrBlocks :alert:"
  slack_message_template = "Monitor {{ctx.monitor.name}} just entered alert status.\nThe subnet does not have enough free cidr blocks to assign IP prefix, please investigate the issue and check logs for more details.\n- Trigger: {{ctx.trigger.name}}\n- Severity: {{ctx.trigger.severity}}"
  alert_throttle_enabled = true
  throttle_value         = 60
  throttle_unit          = "MINUTES"
  environment_name       = var.environment
  alert_query = jsonencode(
    {
      "sort": [
        {
          "@timestamp": {
            "order": "desc",
            "unmapped_type": "boolean"
          }
        }
      ],
      "size":0,
      "query": {
        "bool": {
          "must": [],
          "filter": [
            {
              "multi_match": {
                "type": "phrase",
                "query": "InsufficientCidrBlocks",
                "lenient": true
              }
            },
            {
              "range": {
                "@timestamp": {
                    "from": "{{period_end}}||-1m",
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

module "opensearch_alert_error_loading_seccomp" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch-alert?ref=1.0.2"

  secret_name                    = "live-monitoring-3ca3cc4085f66db3"
  secret_key                     = "url"
  slack_channel_name             = "lower-priority-alarms"
  slack_channel_name_description = "Cloud Platform lower priority alarms channel"
  opensearch_alert_name          = "Error loading seccomp filter - Errno 524"
  opensearch_alert_enabled       = true
  monitor_period_interval        = "1"
  monitor_period_unit            = "MINUTES"
  index                          = ["live_eventrouter*"]

  trigger_name           = "Error loading seccomp filter - Errno 524 trigger"
  serverity              = 1
  query_source           = "ctx.results[0].hits.total.value > 0"
  action_name            = "Error loading seccomp filter - Errno 524 action"
  slack_message_subject  = ":alert: Error loading seccomp filter - Errno 524 :alert:"
  slack_message_template = "Monitor {{ctx.monitor.name}} just entered alert status.\n Investigate logs and recycle problem node. \n- Trigger: {{ctx.trigger.name}}\n- Severity: {{ctx.trigger.severity}}"
  alert_throttle_enabled = true
  throttle_value         = 60
  throttle_unit          = "MINUTES"
  environment_name       = var.environment
  alert_query = jsonencode(
    {
      "sort": [
        {
          "@timestamp": {
            "order": "desc",
            "unmapped_type": "boolean"
          }
        }
      ],
      "size":0,
      "query": {
        "bool": {
          "must": [],
          "filter": [
            {
              "multi_match": {
                "type": "phrase",
                "query": "error loading seccomp filter: errno 524",
                "lenient": true
              }
            },
            {
              "range": {
                "@timestamp": {
                    "from": "{{period_end}}||-1m",
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

module "opensearch_alert_error_qps_exceeded" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch-alert?ref=1.0.2"

  secret_name                    = "live-monitoring-3ca3cc4085f66db3"
  secret_key                     = "url"
  slack_channel_name             = "lower-priority-alarms"
  slack_channel_name_description = "Cloud Platform lower priority alarms channel"
  opensearch_alert_name          = "Pull QPS exceeded alert"
  opensearch_alert_enabled       = true
  monitor_period_interval        = "1"
  monitor_period_unit            = "MINUTES"
  index                          = ["live_eventrouter*"]

  trigger_name           = "Pull QPS exceeded trigger"
  serverity              = 1
  query_source           = "ctx.results[0].hits.total.value > 0"
  action_name            = "Pull QPS exceeded action"
  slack_message_subject  = ":alert: Error: Pull QPS exceeded :alert:"
  slack_message_template = "Monitor {{ctx.monitor.name}} just entered alert status.\n Investigate logs. \n- Trigger: {{ctx.trigger.name}}\n- Severity: {{ctx.trigger.severity}}"
  alert_throttle_enabled = true
  throttle_value         = 60
  throttle_unit          = "MINUTES"
  environment_name       = var.environment
  alert_query = jsonencode(
    {
      "sort": [
        {
          "@timestamp": {
            "order": "desc",
            "unmapped_type": "boolean"
          }
        }
      ],
      "size":0,
      "query": {
        "bool": {
          "must": [],
          "filter": [
            {
              "multi_match": {
                "type": "phrase",
                "query": "pull QPS exceeded",
                "lenient": true
              }
            },
            {
              "range": {
                "@timestamp": {
                    "from": "{{period_end}}||-1m",
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

module "opensearch_alert_failedcreatepodsandbox_assign_ip" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch-alert?ref=1.0.2"

  secret_name                    = "live-monitoring-3ca3cc4085f66db3"
  secret_key                     = "url"
  slack_channel_name             = "lower-priority-alarms"
  slack_channel_name_description = "Cloud Platform lower priority alarms channel"
  opensearch_alert_name          = "FailedCreatePodSandBox - failed to assign an IP address to container"
  opensearch_alert_enabled       = true
  monitor_period_interval        = "1"
  monitor_period_unit            = "MINUTES"
  index                          = ["live_eventrouter*"]

  trigger_name           = "FailedCreatePodSandBox - failed to assign an IP address to container trigger"
  serverity              = 1
  query_source           = "ctx.results[0].hits.total.value > 0"
  action_name            = "FailedCreatePodSandBox - failed to assign an IP address to container action"
  slack_message_subject  = ":alert: FailedCreatePodSandBox - failed to assign an IP address to container :alert:"
  slack_message_template = "Monitor {{ctx.monitor.name}} just entered alert status.\n Investigate logs. \n- Trigger: {{ctx.trigger.name}}\n- Severity: {{ctx.trigger.severity}}"
  alert_throttle_enabled = true
  throttle_value         = 60
  throttle_unit          = "MINUTES"
  environment_name       = var.environment
  alert_query = jsonencode(
    {
      "sort": [
        {
          "@timestamp": {
            "order": "desc",
            "unmapped_type": "boolean"
          }
        }
      ],
      "size":0,
      "query": {
        "bool": {
          "must": [],
          "filter": [
            {
              "multi_match": {
                "type": "phrase",
                "query": "FailedCreatePodSandBox",
                "lenient": true
              }
            },
            {
              "multi_match": {
                "type": "phrase",
                "query": "failed to assign an IP address to container",
                "lenient": true
              }
            },
            {
              "range": {
                "@timestamp": {
                    "from": "{{period_end}}||-1m",
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