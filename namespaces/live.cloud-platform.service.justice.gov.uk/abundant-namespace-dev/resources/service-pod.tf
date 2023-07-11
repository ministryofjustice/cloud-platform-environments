module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=first-pass" # use the latest release

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name
}
