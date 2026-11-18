module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.1"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  # Creates KUBE_CERT, KUBE_TOKEN, KUBE_CLUSTER and KUBE_NAMESPACE secrets in the GitHub environment
  github_repositories = [local.github_repository]
  github_environments = [var.environment]

  depends_on = [github_repository_environment.production]
}
