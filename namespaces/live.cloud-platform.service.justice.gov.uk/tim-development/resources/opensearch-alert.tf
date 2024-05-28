module "opensearch_alert" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch-alerts?ref=opensearch-alert-for-user"

  opensearch_alert_name    = "Grafana duplicate UID"
  opensearch_alert_enabled = true
  monitor_period_interval  = 1
  monitor_period_unit      = "MINUTES"
  query_start_time         = "{{period_end}}||-10m"
  query_end_time           = "{{period_end}}"
  query_source             = "ctx.results[0].hits.total.value > 1"
  trigger_id               = "test"
  trigger_name             = "test"
  action_id                = "test"
  action_name              = "test"
  slack_config_id          = "test"
  slack_name               = "test"
  slack_description        = "test"
  aws_secret_name          = "test"
  k8s_secret_name          = "test"
}