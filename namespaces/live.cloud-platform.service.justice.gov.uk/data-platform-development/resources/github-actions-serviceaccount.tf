module "github_actions_serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.8.1"

  kubernetes_cluster  = var.kubernetes_cluster
  namespace           = var.namespace
  serviceaccount_name = "github-actions"

  github_repositories = ["data-platform"]

  github_actions_secret_kube_cluster   = "CLOUD_PLATFORM_DATA_PLATFORM_DEVELOPMENT_KUBE_CLUSTER"
  github_actions_secret_kube_namespace = "CLOUD_PLATFORM_DATA_PLATFORM_DEVELOPMENT_KUBE_NAMESPACE"
  github_actions_secret_kube_cert      = "CLOUD_PLATFORM_DATA_PLATFORM_DEVELOPMENT_KUBE_CERT"
  github_actions_secret_kube_token     = "CLOUD_PLATFORM_DATA_PLATFORM_DEVELOPMENT_KUBE_TOKEN"
}
