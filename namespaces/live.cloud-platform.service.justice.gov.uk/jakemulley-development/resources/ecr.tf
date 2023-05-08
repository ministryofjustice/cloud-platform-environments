# No entry (also original, 5.1.1)
module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=oidc-refactor"

  team_name = var.team_name
  repo_name = "oidc-test"

  github_repositories = ["cloud-platform-ecr-oidc-test"]
}

# GitHub
module "ecr_github" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=oidc-refactor"

  team_name = var.team_name
  repo_name = "oidc-test"

  github_repositories = ["cloud-platform-ecr-oidc-test"]
  oidc_providers      = ["github"]
}

# CircleCI
module "ecr_circleci" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=oidc-refactor"

  team_name = var.team_name
  repo_name = "oidc-test"

  github_repositories = ["cloud-platform-ecr-oidc-test"]
  oidc_providers      = ["circleci"]
}

# Both
module "ecr_github_circleci" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=oidc-refactor"

  team_name = var.team_name
  repo_name = "oidc-test"

  github_repositories = ["cloud-platform-ecr-oidc-test"]
  oidc_providers      = ["github", "circleci"]
}
