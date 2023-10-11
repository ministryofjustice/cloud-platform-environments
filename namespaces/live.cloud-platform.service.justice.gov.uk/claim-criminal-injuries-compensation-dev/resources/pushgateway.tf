module "pushgateway" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-pushgateway?ref=bump-versions"

  enable_service_monitor = var.service_monitor
  namespace              = var.namespace
}
