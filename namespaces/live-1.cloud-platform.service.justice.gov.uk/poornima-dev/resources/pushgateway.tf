
module "pushgateway" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-pushgateway?ref=remove-data"
  namespace                     = var.namespace
}


