module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.8.1"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  github_repositories = [var.repo_name]

  # This module is also used in the staging namespace, so we must change the
  # secret names here in order to not overwrite the existing ones.

  github_actions_secret_kube_cert      = "KUBE_PROD_CERT"
  github_actions_secret_kube_token     = "KUBE_PROD_TOKEN"
  github_actions_secret_kube_cluster   = "KUBE_PROD_CLUSTER"
  github_actions_secret_kube_namespace = "KUBE_PROD_NAMESPACE"
}
