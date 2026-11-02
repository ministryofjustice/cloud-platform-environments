module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.2"

  repo_name = var.namespace

  # set this if you use one GitHub repository to push to multiple container repositories
  # this ensures the variable key used in the workflow is unique
  github_actions_prefix = "dev"

  # enable the oidc implementation for GitHub
  oidc_providers = ["github"]

  # specify which GitHub repository you're pushing from
  github_repositories = [var.github_repository]

  lifecycle_policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Retain the latest 30 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
