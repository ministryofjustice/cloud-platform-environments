/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "track_a_query_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=6.1.0"
  repo_name = "track-a-query-ecr" # Arbitrary module name does not need to reference any existing modules

  providers = {
    aws = aws.london
  }

  github_repositories = [var.repo_name]
  oidc_providers      = ["circleci", "github"]

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
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "track_a_query_ecr_credentials" {
  metadata {
    name      = "track-a-query-ecr-credentials-output"
    namespace = var.namespace
  }

  data = {
    repo_arn = module.track_a_query_ecr_credentials.repo_arn
    repo_url = module.track_a_query_ecr_credentials.repo_url
  }
}
