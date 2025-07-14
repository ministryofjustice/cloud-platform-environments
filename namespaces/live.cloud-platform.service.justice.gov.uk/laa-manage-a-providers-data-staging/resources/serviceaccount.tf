module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "10-07-2025"

  github_repositories = ["laa-manage-a-providers-data"]
  github_environments = ["staging"]
}
