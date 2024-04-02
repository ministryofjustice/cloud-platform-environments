module "serviceaccount" {
  source              = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=remove-sa-secret-ref"
  namespace           = var.namespace
  kubernetes_cluster  = var.kubernetes_cluster
  serviceaccount_name = "circleci"
  role_name           = "circleci"
}
