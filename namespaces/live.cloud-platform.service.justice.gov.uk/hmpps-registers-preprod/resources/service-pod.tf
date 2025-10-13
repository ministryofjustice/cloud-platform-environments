module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.0.0"

  # Configuration
  namespace            = var.namespace

  # this uses the service account name from the irsa module
  service_account_name = module.irsa.service_account.name
}
