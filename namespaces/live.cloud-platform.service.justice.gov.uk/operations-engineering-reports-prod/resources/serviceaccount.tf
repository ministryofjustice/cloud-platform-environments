module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.8.1"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  github_repositories = ["operations-engineering-reports"]

  github_actions_secret_kube_token     = "PROD_KUBE_TOKEN"
  github_actions_secret_kube_cert      = "PROD_KUBE_CERT"
  github_actions_secret_kube_namespace = "PROD_KUBE_NAMESPACE"
  github_actions_secret_kube_cluster   = "PROD_KUBE_CLUSTER"
}
