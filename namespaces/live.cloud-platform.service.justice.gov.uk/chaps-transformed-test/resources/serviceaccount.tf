module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace            = var.namespace
  kubernetes_cluster   = var.kubernetes_cluster
  serviceaccount_rules = var.service_account_rules

  #  Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories = ["chaps"]
  github_environments = [var.environment]
}
