module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.2.1"

  namespace                = var.namespace
  service_account_name     = module.irsa.service_account.name # this uses the service account name from the irsa module
  override_deployment_name = "laa-criminal-applications-datastore-staging-service-pod"
}
