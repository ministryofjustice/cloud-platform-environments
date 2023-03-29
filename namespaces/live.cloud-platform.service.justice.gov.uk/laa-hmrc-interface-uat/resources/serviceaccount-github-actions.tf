module "serviceaccount_github_actions" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.8.1"

  namespace            = var.namespace
  kubernetes_cluster   = var.kubernetes_cluster
  serviceaccount_name  = "github-actions"
  serviceaccount_rules = var.serviceaccount_github_actions_rules

  role_name        = "serviceaccount-github-action-role"
  rolebinding_name = "serviceaccount-github-action-binding"

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories                  = [var.repo_name]
  github_actions_secret_kube_cert      = "K8S_GHA_UAT_CLUSTER_CERT"
  github_actions_secret_kube_token     = "K8S_GHA_UAT_TOKEN"
  github_actions_secret_kube_cluster   = "K8S_GHA_UAT_CLUSTER_NAME"
  github_actions_secret_kube_namespace = "K8S_GHA_UAT_NAMESPACE"
}
