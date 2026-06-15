# Egress controls for hmpps-templates namespace
# Deploys Envoy HTTPS forward proxy and creates proxy environment secret
# For guidance see: https://tech-docs.hmpps.service.justice.gov.uk/how-to-guides/retrofitting-egress-controls-with-envoy-proxy

module "hmpps_egress_controls" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-egress-controls?ref=0.0.3"

  enable_envoy_setup     = true
  
  # Add known external endpoint/suffixes your apps in this namespace 
  # need to connect to (egress only) and then set this to true to secure
  # your namespace from unexpected egress 
  enable_egress_controls = false 

  namespace = var.namespace
  vpc_name  = var.vpc_name

  # Optional: Add additional allowed hosts/suffixes used by apps in this namespace
  # envoy_extra_allowed_hosts_exact = [
  #   "api.example.com",
  # ]
  # envoy_extra_allowed_hosts_suffixes = [
  #   ".example.com",
  # ]
}
