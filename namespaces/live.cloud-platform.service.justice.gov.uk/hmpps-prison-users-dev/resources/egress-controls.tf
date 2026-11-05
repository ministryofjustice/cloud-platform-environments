module "hmpps_egress_controls" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-egress-controls?ref=0.0.11"

  namespace          = var.namespace
  enable_envoy_setup = true
  vpc_name           = var.vpc_name

  # Add your service's external dependencies
  envoy_extra_allowed_hosts_exact = [
  ]

  envoy_extra_allowed_hosts_suffixes = [
  ]
}