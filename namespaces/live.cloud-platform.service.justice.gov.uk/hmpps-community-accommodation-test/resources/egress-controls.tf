module "hmpps_egress_controls" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-egress-controls?ref=0.0.10"

  namespace          = var.namespace
  enable_envoy_setup = true
  vpc_name           = var.vpc_name

  envoy_extra_allowed_hosts_exact = [
    "api.notifications.service.gov.uk",  # GOV.UK Notify
    "api.os.uk",                         # Ordnance Survey Places API
    "www.gov.uk",                        # bank-holidays.json file
    "${module.s3_bucket.bucket_name}.s3.eu-west-2.amazonaws.com", # CAS data science report uploads
  ]

  envoy_extra_allowed_hosts_suffixes = [
  ]
}