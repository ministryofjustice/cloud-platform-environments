module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  serviceaccount_name  = "circleci"
  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster
  serviceaccount_rules = var.serviceaccount_rules

  serviceaccount_token_rotated_date = "07-10-2024"

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  # github_repositories = ["laa-submit-crime-forms"]
}
