/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "ecr_feed_parser" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"
  repo_name = "${var.namespace}-feed-parser-ecr"

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

  # enable the oidc implementation for GitHub
  oidc_providers = ["github"]

  # Uncomment and provide repository names to create github actions secrets
  # containing the ECR name, AWS access key, and AWS secret key, for use in
  # github actions CI/CD pipelines
  github_repositories = ["feed-parser"]

  # Create secrets in target GitHub environment
  # https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#environment-secrets
  # github_environments = []

  # OPTIONAL:
  # set this if you use one GitHub repository to push to multiple container repositories
  # this ensures the variable key used in the workflow is unique
  github_actions_prefix = "demo"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "ecr_feed_parser" {
  metadata {
    name      = "ecr-repo-feed-parser-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    repo_arn = module.ecr_feed_parser.repo_arn
    repo_url = module.ecr_feed_parser.repo_url
  }
}
