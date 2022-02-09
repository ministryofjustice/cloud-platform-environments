module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.7.3"

  namespace           = var.namespace
  serviceaccount_name = "circleci"
  kubernetes_cluster  = var.kubernetes_cluster

}
