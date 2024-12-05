module "github_actions_serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  kubernetes_cluster  = var.kubernetes_cluster
  namespace           = var.namespace
  serviceaccount_name = "github-actions"
}
