module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "01-01-2000"

  github_repositories = [
    "laa-fee-scheme-api",
    "bulk-submission-and-fee-scheme-tests-"
  ]
  github_environments = ["uat"]
}
