module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = var.team_name
  repo_name = var.repo_name

  # enable the oidc implementation for GitHub
  oidc_providers = ["github"]

  github_repositories = [var.repo_name]

  lifecycle_policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images keeping newest 200",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 200
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
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo"
    namespace = var.namespace
  }

  data = {
    repo_url = module.ecr-repo.repo_url
    repo_arn = module.ecr-repo.repo_arn
  }
}
