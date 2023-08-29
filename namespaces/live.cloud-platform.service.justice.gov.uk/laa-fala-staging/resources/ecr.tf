module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"

  team_name = var.team_name
  repo_name = var.repo_name

  providers = {
    aws = aws.london
  }
  # enable the oidc implementation for CircleCI
  oidc_providers = ["circleci"]

  # specify which GitHub repository your CircleCI job runs from
  github_repositories = [var.repo_name, "cla-end-to-end-tests", "cla_backend", "cla_frontend", "cla_public"]

  # set your namespace name to create a ConfigMap
  # of credentials you need in CircleCI
  namespace = var.namespace
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-laa-fala"
    namespace = var.namespace
  }

  data = {
    repo_url          = module.ecr-repo.repo_url
  }
}

