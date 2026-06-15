# Egress controls for hmpps-templates namespace
# Deploys Envoy HTTPS forward proxy and creates proxy environment secret
# For guidance see: https://tech-docs.hmpps.service.justice.gov.uk/how-to-guides/retrofitting-egress-controls-with-envoy-proxy

module "hmpps_egress_controls" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-egress-controls?ref=0.0.3"

  # Stage 1: Deploy proxy without enforcement (no Calico network policies yet)
  # This allows applications to be configured to use the proxy before enforcement is enabled
  enable_envoy_setup     = true
  enable_egress_controls = false

  namespace = var.namespace
  vpc_name  = var.vpc_name

  # Optional: Add additional allowed hosts/suffixes as needed
  # envoy_extra_allowed_hosts_exact = [
  #   "api.example.com",
  # ]
  # envoy_extra_allowed_hosts_suffixes = [
  #   ".example.com",
  # ]
}
