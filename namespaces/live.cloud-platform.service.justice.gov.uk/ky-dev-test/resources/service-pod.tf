module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=optional_override_deployment_name" # use the latest release

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name # this uses the service account name from the irsa module
  service_pod_count = 1
  override_deployment_name = "mycustomname"
}