# Creates an ECR repository for the curator image and configures OIDC-based
# push access. The module automatically creates the following GitHub Actions
# secrets/variables in the specified repositories:
#   - ECR_ROLE_TO_ASSUME  (secret)
#   - ECR_REGION          (variable)
#   - ECR_REPOSITORY      (variable)

module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.1"

  repo_name = "vscode-marketplace"

  oidc_providers      = ["github"]
  github_repositories = [var.github_repository]

  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = { type = "expire" }
      }
    ]
  })

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}
