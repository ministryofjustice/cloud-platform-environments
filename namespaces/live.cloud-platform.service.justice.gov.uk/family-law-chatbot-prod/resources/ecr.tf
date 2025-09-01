module "ecr_credentials" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"

  repo_name        = "${var.namespace}-ecr"
  lifecycle_policy = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Keep the newest 14 images and mark the rest for expiration",
        "selection": {
          "tagStatus": "any",
          "countType": "imageCountMoreThan",
          "countNumber": 14
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
  EOF

  oidc_providers      = ["github"]
  github_repositories = [var.app_repo]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "ecr_credentials" {
  metadata {
    name      = "ecr-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    repo_arn = module.ecr_credentials.repo_arn
    repo_url = module.ecr_credentials.repo_url
  }
}
