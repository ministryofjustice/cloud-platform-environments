# No canned lifecycle policies
module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=add-irsa"

  # REQUIRED: Repository configuration
  team_name = var.team_name
  repo_name = var.namespace
  namespace = var.namespace

  # REQUIRED: OIDC providers to configure, either "github", "circleci", or both
  oidc_providers = ["github"]

  # REQUIRED: GitHub repositories that push to this container repository
  github_repositories = ["example-repository"]

  # OPTIONAL: GitHub environments, to create variables as actions variables in your environments
  # github_environments = ["production"]
}
