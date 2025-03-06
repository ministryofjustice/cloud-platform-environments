module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.2.0" # use the latest release

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa_offender_categorisation.service_account.name # this uses the service account name from the irsa module
  service_pod_count = 3
}