module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "01-01-2000"

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories                  = ["github-community"]
  github_actions_secret_kube_namespace = "PROD_KUBE_NAMESPACE"
  github_actions_secret_kube_cert      = "PROD_KUBE_CERT"
  github_actions_secret_kube_token     = "PROD_KUBE_TOKEN"
}
