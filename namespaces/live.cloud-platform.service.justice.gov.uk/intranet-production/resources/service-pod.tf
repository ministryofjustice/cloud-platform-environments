# Service pod for AWS CLI access
module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.2.0"

  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name
}
