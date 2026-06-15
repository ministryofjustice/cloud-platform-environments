# Egress controls for hmpps-templates namespace
# Deploys Envoy HTTPS forward proxy and creates proxy environment secret
# For guidance see: https://tech-docs.hmpps.service.justice.gov.uk/how-to-guides/retrofitting-egress-controls-with-envoy-proxy

module "hmpps_egress_controls" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-egress-controls?ref=0.0.3"

  enable_envoy_setup     = true
  
  # Follow the guidance in the link above to configure your app to use the proxy
  # then set this to true when ready to apply egress denial 
  enable_egress_controls = false 

  namespace = var.namespace
  vpc_name  = var.vpc_name

}
