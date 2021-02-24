module "pushgateway" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-pushgateway?ref=1.1"

  enable_service_monitor = var.service_monitor
  namespace              = var.namespace
}