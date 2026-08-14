# Deploy Envoy and publish its proxy environment secret without replacing the
# existing egress policies. Workloads can be migrated to the proxy separately
# before the module-managed egress controls are enabled.
module "hmpps_egress_controls" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-egress-controls?ref=0.0.10"

  enable_envoy_setup     = true
  enable_egress_controls = false

  namespace = var.namespace
  vpc_name  = var.vpc_name

  envoy_extra_allowed_hosts_exact = [
    "athena.eu-west-1.amazonaws.com",
    "dev.integration-api.hmpps.service.justice.gov.uk",
    "hooks.slack.com",
    "login.microsoftonline.com",
    "s3.eu-west-1.amazonaws.com",
    "s3.eu-west-2.amazonaws.com",
  ]

  envoy_extra_allowed_hosts_suffixes = [
    ".openai.azure.com",
    ".s3.eu-west-1.amazonaws.com",
    ".s3.eu-west-2.amazonaws.com",
  ]
}
