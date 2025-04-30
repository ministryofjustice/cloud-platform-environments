# Just for dev, crete a service pod with the irsa role, so that we can upload resources to the S3 bucket.
module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.2.0"

  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name
}
