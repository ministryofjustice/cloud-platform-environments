module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=version"

  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name
  service_pod_count    = 0
}