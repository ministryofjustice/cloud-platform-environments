module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace           = var.namespace
  kubernetes_cluster  = var.kubernetes_cluster

  # Creates repo-level secrets (ca.crt / token / server)
  github_repositories = ["gov-reuse"]
  github_actions_secret_kube_namespace = "PREPROD_KUBE_NAMESPACE"
  github_actions_secret_kube_cert      = "PREPROD_KUBE_CERT"
  github_actions_secret_kube_token     = "PREPROD_KUBE_TOKEN"

  serviceaccount_token_rotated_date = "30-04-2026"
}
