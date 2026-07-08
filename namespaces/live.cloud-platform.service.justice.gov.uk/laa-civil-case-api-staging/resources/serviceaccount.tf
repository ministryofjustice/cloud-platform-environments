module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "20-03-2026"

  # Creates Kubernetes' GitHub actions secrets in the repository
  github_repositories = ["laa-civil-case-api"]
  github_environments = ["staging"]
}
