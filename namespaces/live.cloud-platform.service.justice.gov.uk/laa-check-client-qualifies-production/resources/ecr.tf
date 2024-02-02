/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=6.1.0"
  team_name = var.team_name
  repo_name = "laa-check-client-qualifies-ecr"

  # enable the oidc implementation for CircleCI
  oidc_providers = ["circleci"]

  # specify which GitHub repository your CircleCI job runs from
  github_repositories = ["laa-check-client-qualifies"]

  # set your namespace name to create a ConfigMap of credentials you need in CircleCI
  namespace = var.namespace

  # list of github environments, to create the ECR secrets as environment secrets
  # https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#environment-secrets
  # github_environments = ["my-environment"]

  # Lifecycle_policy provides a way to automate the cleaning up of your container images by expiring images based on age or count.
  # To apply multiple rules, combined them in one policy JSON.
  # https://docs.aws.amazon.com/AmazonECR/latest/userguide/lifecycle_policy_examples.html

  # Production images are tagged with "main". Other images are tagged "branch".
  lifecycle_policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep the newest 1000 UAT images (100 branches, 10 commits on each)",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["branch"],
                "countType": "imageCountMoreThan",
                "countNumber": 1000
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Keep the newest 100 production images and mark the rest for expiration",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["main"],
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
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "ecr_credentials" {
  metadata {
    name      = "ecr-repo-laa-check-client-qualifies"
    namespace = var.namespace
  }

  data = {
    repo_arn = module.ecr_credentials.repo_arn
    repo_url = module.ecr_credentials.repo_url
  }
}
