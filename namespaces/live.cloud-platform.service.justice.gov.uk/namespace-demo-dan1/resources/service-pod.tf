module "service_pod_debian13" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.3.0"

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name # this uses the service account name from the irsa module
  override_deployment_name = "sp-debian13"
}
