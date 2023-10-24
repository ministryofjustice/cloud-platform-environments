module "serviceaccount" {
  source              = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.0.0"
  serviceaccount_name = "circleci"
  namespace           = var.namespace
  kubernetes_cluster  = var.kubernetes_cluster

}
