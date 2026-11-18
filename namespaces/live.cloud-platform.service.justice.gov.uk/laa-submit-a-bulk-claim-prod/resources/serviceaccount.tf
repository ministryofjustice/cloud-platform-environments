module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.1"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster
  serviceaccount_name = var.serviceaccount_name

  github_repositories = ["laa-submit-a-bulk-claim"]
  github_environments = ["production"]
  serviceaccount_token_rotated_date = "20-03-2026"
}
