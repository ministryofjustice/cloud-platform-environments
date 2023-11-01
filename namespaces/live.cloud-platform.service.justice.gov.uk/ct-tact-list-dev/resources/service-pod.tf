module "service_pod" {
  # use the latest release"
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.0.0"

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name # see irsa.tf for an example of irsa
}
