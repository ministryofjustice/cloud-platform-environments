module "ecr" {
  oidc_providers = ["circleci"]

  github_repositories = ["fb-deploy"]

  namespace = var.namespace
}
