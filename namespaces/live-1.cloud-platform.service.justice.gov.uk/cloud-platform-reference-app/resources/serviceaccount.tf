module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.7.4"

  namespace           = var.namespace
  serviceaccount_name = "circleci-live1"
  kubernetes_cluster  = var.kubernetes_cluster
}
