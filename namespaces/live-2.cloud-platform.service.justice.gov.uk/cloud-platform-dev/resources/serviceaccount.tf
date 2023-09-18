module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=mount-secrets"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

}
