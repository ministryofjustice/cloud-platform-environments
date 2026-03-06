module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"

  # Repository configuration
  repo_name = var.namespace

  # OpenID Connect configuration
  oidc_providers         = ["github"]
  github_repositories    = var.github_repository_names
  github_actions_prefix  = "DPD"  # prefix for ECR_* secrets

  # Lifecycle Policy
  lifecycle_policy = <<EOF
    {
      "rules": [
        {
          "rulePriority": 1,
          "description": "Keep latest 300 PR images",
          "selection": {
            "tagStatus": "tagged",
            "tagPrefixList": ["pr"],
            "countType": "imageCountMoreThan",
            "countNumber": 300
          },
          "action": { "type": "expire" }
        },
        {
          "rulePriority": 2,
          "description": "Expire version-tagged images older than 365 days",
          "selection": {
            "tagStatus": "tagged",
            "tagPrefixList": ["v"],
            "countType": "sinceImagePushed",
            "countUnit": "days",
            "countNumber": 365
          },
          "action": { "type": "expire" }
        }
      ]
    }
    EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name  # also used for naming the container repository
  namespace              = var.namespace  # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
