module "ecr_credentials_new" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=teamname-bug-fix"

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

  legacy_ecr_naming = true
  repo_name = "ecr-testing-two"

  oidc_providers = ["github"]
  github_repositories = ["sw-ecr-testing"]
  github_actions_prefix = "foo"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "ecr_credentials_two" {
  metadata {
    name      = "ecr-${var.namespace}-two"
    namespace = var.namespace
  }

  data = {
    repo_arn = module.ecr_credentials_new.repo_arn
    repo_url = module.ecr_credentials_new.repo_url
  }
}