module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace                        = var.namespace
  kubernetes_cluster               = var.kubernetes_cluster
  serviceaccount_token_rotated_date = "01-01-2000"

  github_repositories = ["justice-redact-frontend", "justice-redact-backend"]

  # Scope KUBE_* secrets to the 'staging' GitHub environment
  # This prevents conflicts with dev/prod writing the same repo-level secrets
  github_environments = ["staging"]
}
