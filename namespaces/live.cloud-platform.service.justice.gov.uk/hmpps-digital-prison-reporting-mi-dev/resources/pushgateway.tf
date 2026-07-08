# Pushgateway for pushing batch/ephemeral metrics to Prometheus
# See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/monitoring-an-app/prometheus.html#using-the-cloud-platform-monitoring-and-alerting-stack

module "pushgateway" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-pushgateway?ref=1.4.0"

  enable_service_monitor = var.service_monitor
  namespace              = var.namespace
}

