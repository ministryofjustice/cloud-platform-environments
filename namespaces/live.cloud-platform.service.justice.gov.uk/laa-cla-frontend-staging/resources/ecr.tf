module "cla_frontend_app_credentials" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = var.team_name
  repo_name = var.repo_name

  providers = {
    aws = aws.london
  }
  # enable the oidc implementation for CircleCI
  oidc_providers = ["circleci"]

  # specify which GitHub repository your CircleCI job runs from
  github_repositories = [var.repo_name, "cla-end-to-end-tests", "cla_backend", "cla_public", "fala"]

  # set your namespace name to create a ConfigMap
  # of credentials you need in CircleCI
  namespace = var.namespace

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "cla_frontend_app_credentials" {
  metadata {
    name      = "ecr-repo-laa-cla-frontend"
    namespace = var.namespace
  }

  data = {
    repo_url = module.cla_frontend_app_credentials.repo_url
  }
}

module "cla_frontend_socket_server_credentials" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = var.team_name
  repo_name = "cla_frontend_socket_server"

  providers = {
    aws = aws.london
  }

  # enable the oidc implementation for CircleCI
  oidc_providers = ["circleci"]

  # specify which GitHub repository your CircleCI job runs from
  github_repositories = [var.repo_name, "cla-end-to-end-tests", "cla_backend", "cla_public", "fala"]

  # set your namespace name to create a ConfigMap
  # of credentials you need in CircleCI
  namespace = var.namespace

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "cla_frontend_socket_server_credentials" {
  metadata {
    name      = "ecr-repo-laa-cla-frontend-socket-server"
    namespace = var.namespace
  }

  data = {
    repo_url = module.cla_frontend_socket_server_credentials.repo_url
  }
}
