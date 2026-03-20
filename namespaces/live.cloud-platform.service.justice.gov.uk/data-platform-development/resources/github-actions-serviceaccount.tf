module "github_actions_serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  kubernetes_cluster  = var.kubernetes_cluster
  namespace           = var.namespace
  serviceaccount_name = "github-actions"
  serviceaccount_token_rotated_date = "20-03-2026"
}
