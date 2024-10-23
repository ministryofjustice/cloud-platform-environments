module "service_pod" {
  source = "github.com/markreesmoj/cloud-platform-terraform-service-pod?ref=PIC-4134-service-account-name-in-pod-name" # use the latest release

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name
}
