module "circleci_service_account" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace            = var.namespace
  kubernetes_cluster   = var.kubernetes_cluster
  serviceaccount_rules = var.serviceaccount_rules
  serviceaccount_name  = "circleci"
  role_name            = "circleci"
  rolebinding_name     = "circleci"
}
