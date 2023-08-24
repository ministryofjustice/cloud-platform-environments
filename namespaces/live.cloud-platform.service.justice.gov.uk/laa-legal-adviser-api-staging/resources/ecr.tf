module "ecr-repo-api" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"

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
}

resource "kubernetes_secret" "ecr-repo-api" {
  metadata {
    name      = "ecr-repo-laa-legal-adviser-api"
    namespace = "laa-legal-adviser-api-staging"
  }

  data = {
    repo_url          = module.ecr-repo-api.repo_url
    access_key_id     = module.ecr-repo-api.access_key_id
    secret_access_key = module.ecr-repo-api.secret_access_key
  }
}

