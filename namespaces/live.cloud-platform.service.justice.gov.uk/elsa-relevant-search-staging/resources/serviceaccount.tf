module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.7.3"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  github_repositories = [var.github_repo_name]
}
