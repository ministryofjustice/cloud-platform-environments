module "service_pod_100" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.0.0"

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name # this uses the service account name from the irsa module
}

module "service_pod_121" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.2.1"

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name # this uses the service account name from the irsa module
}
