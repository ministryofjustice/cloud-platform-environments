module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.3.0"

  # Configuration
  override_deployment_name = "service-pod"
  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name # this uses the service account name from the irsa module
}

module "service_pod_holds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.3.0"

  # Configuration
  override_deployment_name =  "holds-service-pod"
  namespace            = var.namespace
  service_account_name = module.holds_irsa.service_account.name # this uses the service account name from the irsa module
}

module "service_pod_advances" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.3.0"

  # Configuration
  override_deployment_name =  "advances-service-pod"
  namespace            = var.namespace
  service_account_name = module.advances_irsa.service_account.name # this uses the service account name from the irsa module
}

module "service_pod_subscriptions" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.3.0"

  # Configuration
  override_deployment_name =  "subscriptions-service-pod"
  namespace            = var.namespace
  service_account_name = module.subscriptions_irsa.service_account.name # this uses the service account name from the irsa module
}