module "pushgateway" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-pushgateway?ref=1.3.0"
  namespace = var.namespace
}
