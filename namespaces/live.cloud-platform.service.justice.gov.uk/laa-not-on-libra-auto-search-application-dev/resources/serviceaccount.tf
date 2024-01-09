module "serviceaccount-github" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.0.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "01-01-2000"

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories = ["laa-nolasa"]
  github_environments = ["development"]

  serviceaccount_name = "github-actions"

  role_name        = "serviceaccount-role-github"
  rolebinding_name = "serviceaccount-rolebinding-github"

}