module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  # Repository configuration
  repo_name = var.namespace

  # OIDC providers to configure, either "github", "circleci", or both
  oidc_providers = ["circleci"]

  # GitHub repositories that push to this container repository
  github_repositories = [var.repo_name]

  # GitHub environments, to create variables as actions variables in your environments
  # github_environments = ["development"]

  # Lifecycle policies
  # For tidying up old docker images
  lifecycle_policy = <<EOF
    {
      "rules": [
        {
          "rulePriority": 1,
          "description": "Expire untagged images older than 14 days",
          "selection": {
            "tagStatus": "untagged",
            "countType": "sinceImagePushed",
            "countUnit": "days",
            "countNumber": 14
          },
          "action": {
            "type": "expire"
          }
        },
        {
          "rulePriority": 2,
          "description": "Keep last 30 dev and staging images",
          "selection": {
            "tagStatus": "tagged",
            "tagPrefixList": ["dev", "staging"],
            "countType": "imageCountMoreThan",
            "countNumber": 30
          },
          "action": {
            "type": "expire"
          }
        },
        {
          "rulePriority": 3,
          "description": "Keep the newest 100 images and mark the rest for expiration",
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

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
