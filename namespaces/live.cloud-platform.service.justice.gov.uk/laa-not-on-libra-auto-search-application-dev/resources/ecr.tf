module "ecr" {
  ...
  # REQUIRED: OIDC providers to configure, either "github", "circleci", or both
  oidc_providers = ["circleci"]

  # REQUIRED: GitHub repositories that push to this container repository
  github_repositories = ["laa-nolasa"]

  # This is the namespace to create a ConfigMap
  # of credentials you need in CircleCI
  namespace = laa-not-on-libra-auto-search-application-dev
  ...
}