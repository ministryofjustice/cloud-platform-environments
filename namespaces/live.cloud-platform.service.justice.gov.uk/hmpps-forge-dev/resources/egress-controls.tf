module "hmpps_egress_controls" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-egress-controls?ref=0.0.3"

  enable_envoy_setup     = true
  enable_egress_controls = false # Stage 2: set to true once the app is confirmed to route via the proxy
  namespace              = var.namespace
  vpc_name               = var.vpc_name
}
