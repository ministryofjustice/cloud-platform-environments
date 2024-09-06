module "pushgateway" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-pushgateway?ref=version" # use the latest relase
  namespace = var.namespace
}
