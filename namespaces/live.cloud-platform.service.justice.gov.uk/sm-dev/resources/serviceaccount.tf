module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.6"

  namespace           = var.namespace
  serviceaccount_name = "circleci"
}
