module "ecr_credentials" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=6.1.0"

  repo_name = "${var.namespace}-ecr"

  # Uncomment and provide repository names to create github actions secrets
  # containing the ECR name, AWS access key, and AWS secret key, for use in
  # github actions CI/CD pipelines

  # enable the oidc implementation for github
  oidc_providers = ["github"]

  github_repositories = ["SOCReporting", "SOCEntry"]

  lifecycle_policy = <<EOF
  {
    "rules": [
      {
          "rulePriority": 1,
          "description": "Keep the newest 20 production images and mark the rest for expiration",
          "selection": {
              "tagStatus": "tagged",
              "tagPrefixList": ["production-reporting", "dev-reporting", "staging-reporting", "entry-dev", "entry-staging", "entry-production"],
              "countType": "imageCountMoreThan",
              "countNumber": 20
          },
          "action": {
              "type": "expire"
          }
      },
      {
          "rulePriority": 2,
          "description": "Expire images older than 30 days",
          "selection": {
              "tagStatus": "any",
              "countType": "sinceImagePushed",
              "countUnit": "days",
              "countNumber": 90
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

resource "kubernetes_secret" "ecr_credentials" {
  metadata {
    name      = "ecr-repo-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    repo_arn = module.ecr_credentials.repo_arn
    repo_url = module.ecr_credentials.repo_url
  }
}
