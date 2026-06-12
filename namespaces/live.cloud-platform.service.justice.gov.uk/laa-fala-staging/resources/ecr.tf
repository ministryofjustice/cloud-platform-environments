module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"

  team_name = var.team_name
  repo_name = var.repo_name

  providers = {
    aws = aws.london
  }
  # enable the oidc implementation for CircleCI
  oidc_providers = ["circleci", "github"]

  # specify which GitHub repository your CircleCI job runs from
  github_repositories = [var.repo_name]
  github_actions_prefix = "FALA"

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

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-laa-fala"
    namespace = var.namespace
  }

  data = {
    repo_url = module.ecr-repo.repo_url
  }
}
