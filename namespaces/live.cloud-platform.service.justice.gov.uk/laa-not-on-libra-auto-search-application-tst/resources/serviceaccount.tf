module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.9.6"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "01-01-2000"

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  # github_repositories = ["my-repo"]

  serviceaccount_name = "circleci"
  
}

module "serviceaccount-github" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.9.7"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "01-01-2000"

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories = ["laa-nolasa"]

  serviceaccount_name = "github-actions"

  role_name = "serviceaccount-role-github"
  rolebinding_name = "serviceaccount-rolebinding-github"

}
