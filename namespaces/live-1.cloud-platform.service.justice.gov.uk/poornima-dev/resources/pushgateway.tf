
module "pushgateway" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-pushgateway?ref=1.0"
  namespace                     = var.namespace
}


