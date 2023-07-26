module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.9.5"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  github_repositories = [var.repo_name]
}
