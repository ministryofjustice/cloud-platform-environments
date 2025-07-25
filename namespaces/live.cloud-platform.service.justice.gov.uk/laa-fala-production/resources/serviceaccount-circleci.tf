module "serviceaccount_circleci" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "16-07-2025"

  serviceaccount_name = "circleci-migrated"

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  # github_repositories = ["my-repo"]
  github_repositories                  = [var.repo_name]
  github_environments                  = ["production"]
  github_actions_secret_kube_cert      = "FALA_K8S_CLUSTER_CERT"
  github_actions_secret_kube_token     = "FALA_K8S_TOKEN"
  github_actions_secret_kube_cluster   = "FALA_K8S_CLUSTER_NAME"
  github_actions_secret_kube_namespace = "FALA_K8S_NAMESPACE"
}
