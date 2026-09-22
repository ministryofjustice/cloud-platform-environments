module "service_pod_pf_api" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.3.0"

  # Configuration
  override_deployment_name = "service-pod-pf-api"
  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name # this uses the service account name from the irsa module
}

module "service_pod_holds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.3.0"

  # Configuration
  override_deployment_name =  "service-pod-holds"
  namespace            = var.namespace
  service_account_name = module.hmpps_prisoner_finance_holds_irsa.service_account.name # this uses the service account name from the irsa module
}

module "service_pod_advances" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.3.0"

  # Configuration
  override_deployment_name =  "service-pod-advances"
  namespace            = var.namespace
  service_account_name = module.hmpps_prisoner_finance_advances_irsa.service_account.name # this uses the service account name from the irsa module
}

module "service_pod_subscriptions" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.3.0"

  # Configuration
  override_deployment_name = "service-pod-subscriptions"
  namespace            = var.namespace
  service_account_name = module.hmpps_prisoner_finance_subscriptions_irsa.service_account.name # this uses the service account name from the irsa module
}