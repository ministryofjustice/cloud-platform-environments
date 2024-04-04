module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  github_repositories = ["operations-engineering-metadata-poc"]

  # Using a DEV* prefix here to avoid conflicts with production.
  github_actions_secret_kube_token     = "DEV_KUBE_TOKEN"
  github_actions_secret_kube_cert      = "DEV_KUBE_CERT"
  github_actions_secret_kube_namespace = "DEV_KUBE_NAMESPACE"
  github_actions_secret_kube_cluster   = "DEV_KUBE_CLUSTER"
}
