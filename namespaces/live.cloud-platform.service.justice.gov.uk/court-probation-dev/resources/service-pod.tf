module "court-case-service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.0.1"

  namespace            = var.namespace
  service_account_name = module.court-case-service-irsa.service_account.name
}

module "court-facing-api-service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.0.1"

  namespace            = var.namespace
  service_account_name = module.court-facing-api-irsa.service_account.name
}
