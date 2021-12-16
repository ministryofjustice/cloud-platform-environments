module "pushgateway" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-pushgateway?ref=1.2"
  namespace = var.namespace
}
