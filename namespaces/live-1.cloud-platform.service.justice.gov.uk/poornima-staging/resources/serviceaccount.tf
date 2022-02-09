module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.7.3"

  namespace = var.namespace

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines

  github_repositories = ["helloworld-poornima-dev"]

  kubernetes_cluster                   = var.kubernetes_cluster
  github_actions_secret_kube_namespace = "KUBE_NAMESPACE_LIVE_1"
  github_actions_secret_kube_cert      = "KUBE_CERT_LIVE_1"
  github_actions_secret_kube_token     = "KUBE_TOKEN_LIVE_1"
  github_actions_secret_kube_cluster   = "KUBE_CLUSTER_LIVE_1"
}
