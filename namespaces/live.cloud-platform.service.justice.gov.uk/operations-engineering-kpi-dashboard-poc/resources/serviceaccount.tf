module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "01-01-2000"

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories                  = ["operations-engineering-kpi-dashboard-poc"]
  github_actions_secret_kube_namespace = "POC_KUBE_NAMESPACE"
  github_actions_secret_kube_cert      = "POC_KUBE_CERT"
  github_actions_secret_kube_token     = "POC_KUBE_TOKEN"
}
