module "pushgateway" {
    source    = "github.com/ministryofjustice/cloud-platform-terraform-pushgateway?ref=1.4.0" # use the latest release
    namespace = var.namespace
}