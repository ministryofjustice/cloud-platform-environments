##########################################
# Parliamentary Questions ECR repository #
##########################################

module "pq_ecr_credentials" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  repo_name = var.repo_name

  # enable the oidc implementation for Github Actions
  oidc_providers      = ["github"]
  github_repositories = [var.repo_name]

  lifecycle_policy = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Keep the newest 50 images and mark the rest for expiration",
        "selection": {
          "tagStatus": "any",
          "countType": "imageCountMoreThan",
          "countNumber": 50
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
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "pq_ecr_credentials" {
  metadata {
    name      = "pq-ecr-credentials-output"
    namespace = var.namespace
  }

  data = {
    repo_arn = module.pq_ecr_credentials.repo_arn
    repo_url = module.pq_ecr_credentials.repo_url
  }
}
