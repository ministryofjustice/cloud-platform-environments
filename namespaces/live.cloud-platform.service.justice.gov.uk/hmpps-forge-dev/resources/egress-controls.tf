module "hmpps_egress_controls" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-egress-controls?ref=0.0.2"

  enable_envoy_setup     = true
  enable_egress_controls = true
  namespace              = var.namespace
  vpc_name               = var.vpc_name
}
