module "serviceaccount" {
  source              = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"
  namespace           = var.namespace
  kubernetes_cluster  = var.kubernetes_cluster
  serviceaccount_name = "circleci"
  role_name           = "circleci"
}