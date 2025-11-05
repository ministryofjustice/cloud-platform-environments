module "ecr_credentials" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"

  repo_name = "${var.namespace}-ecr"

  lifecycle_policy = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Keep newest 100 images that are tagged with *-main-*",
        "selection": {
          "tagStatus": "tagged",
          "tagPatternList": ["*-main-*"],
          "countType": "imageCountMoreThan",
          "countNumber": 100
        },
        "action": {
          "type": "expire"
        }
      },
      {
        "rulePriority": 2,
        "description": "Keep newest 20 images that are tagged with *-qa-*",
        "selection": {
          "tagStatus": "tagged",
          "tagPatternList": ["*-qa-*"],
          "countType": "imageCountMoreThan",
          "countNumber": 20
        },
        "action": {
          "type": "expire"
        }
      },
      {
        "rulePriority": 3,
        "description": "Keep the newest 100 images (that don't match the above rules)",
        "selection": {
          "tagStatus": "any",
          "countType": "imageCountMoreThan",
          "countNumber": 100
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
  EOF

  oidc_providers      = ["github"]
  github_repositories = ["intranet"]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
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
