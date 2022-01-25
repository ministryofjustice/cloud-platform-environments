module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.5"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories = ["ministryofjustice/ALB-UnclaimedBalanceindex"]
  github_actions_secret_ecr_name       = var.github_actions_secret_ecr_name
  github_actions_secret_ecr_url        = var.github_actions_secret_ecr_url
  github_actions_secret_ecr_access_key = var.github_actions_secret_ecr_access_key
  github_actions_secret_ecr_secret_key = var.github_actions_secret_ecr_secret_key
}
