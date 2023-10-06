module "ecr-repo-api" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=6.1.0"

  team_name = var.team_name
  repo_name = var.repo_name

  providers = {
    aws = aws.london
  }
  # enable the oidc implementation for CircleCI
  oidc_providers = ["circleci"]

  # specify which GitHub repository your CircleCI job runs from
  github_repositories = [var.repo_name]

  # set your namespace name to create a ConfigMap
  # of credentials you need in CircleCI
  namespace = var.namespace

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.email
}

resource "kubernetes_secret" "ecr-repo-api" {
  metadata {
    name      = "ecr-repo-laa-legal-adviser-api"
    namespace = "laa-legal-adviser-api-staging"
  }

  data = {
    repo_url = module.ecr-repo-api.repo_url
  }
}
