module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace           = var.namespace
  kubernetes_cluster  = var.kubernetes_cluster

  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories = ["gov-reuse"]
  github_actions_secret_kube_namespace = "PROD_KUBE_NAMESPACE"
  github_actions_secret_kube_cert      = "PROD_KUBE_CERT"
  github_actions_secret_kube_token     = "PROD_KUBE_TOKEN"

  serviceaccount_token_rotated_date = "30-04-2026"
}
