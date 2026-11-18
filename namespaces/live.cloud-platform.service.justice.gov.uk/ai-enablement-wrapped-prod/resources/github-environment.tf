locals {
  github_repository = "ai-enablement-wrapped"
}

# GitHub environment that receives the ECR and Kubernetes deployment credentials
resource "github_repository_environment" "production" {
  repository  = local.github_repository
  environment = var.environment

  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }
}
