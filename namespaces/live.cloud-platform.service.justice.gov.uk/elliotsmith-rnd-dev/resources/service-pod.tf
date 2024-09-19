module "service_pod" {
  source = "https://github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.0.1"

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa.service_account_name
}
