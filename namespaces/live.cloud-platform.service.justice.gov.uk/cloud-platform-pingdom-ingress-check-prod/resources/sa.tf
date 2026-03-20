module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  github_repositories = ["cloud-platform-pingdom-ingress-check"]

  serviceaccount_token_rotated_date = "20-03-2026"
}