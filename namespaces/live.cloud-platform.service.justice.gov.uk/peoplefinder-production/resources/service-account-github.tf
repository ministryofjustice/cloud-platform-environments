module "serviceaccount_github" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace          = var.namespace
  kubernetes_cluster = var.eks_cluster_name

  serviceaccount_token_rotated_date = "26-06-2024"

  serviceaccount_name = "github-serviceaccount"
  role_name = "github-serviceaccount"
  rolebinding_name = "github-serviceaccount"

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories = [var.repo_name]
  github_environments = ["production"]
}
