module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.0.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "01-01-2000"


  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories                  = ["operations-engineering-join-github"]
  github_actions_secret_kube_namespace = "DEV_KUBE_NAMESPACE"
  github_actions_secret_kube_cert      = "DEV_KUBE_CERT"
  github_actions_secret_kube_token     = "DEV_KUBE_TOKEN"
}
