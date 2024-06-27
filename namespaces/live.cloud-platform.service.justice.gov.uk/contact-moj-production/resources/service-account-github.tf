module "serviceaccount_github" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  # This module is also used in the staging namespace, so we must change the
  # secret names here in order to not overwrite the existing ones.
  serviceaccount_name = "github-serviceaccount"
  role_name = "github-serviceaccount"
  rolebinding_name = "github-serviceaccount"

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories = [var.repo_name]
  github_environments = ["production"]
}
