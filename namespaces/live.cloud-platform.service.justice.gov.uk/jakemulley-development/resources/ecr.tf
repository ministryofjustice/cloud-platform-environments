# No canned lifecycle policies
module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=canned-lifecycle-policies"

  # REQUIRED: Repository configuration
  team_name = var.team_name
  repo_name = var.namespace
  namespace = var.namespace

  # REQUIRED: OIDC providers to configure, either "github", "circleci", or both
  oidc_providers = ["github", "circleci"]

  # REQUIRED: GitHub repositories that push to this container repository
  github_repositories = ["cloud-platform-ecr-oidc-test"]

  # OPTIONAL: GitHub environments, to create variables as actions variables in your environments
  # github_environments = ["production"]
}

# Custom lifecycle policies
module "ecr_custom" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=canned-lifecycle-policies"

  # REQUIRED: Repository configuration
  team_name = var.team_name
  repo_name = var.namespace
  namespace = var.namespace

  # REQUIRED: OIDC providers to configure, either "github", "circleci", or both
  oidc_providers = ["github", "circleci"]

  # REQUIRED: GitHub repositories that push to this container repository
  github_repositories = ["cloud-platform-ecr-oidc-test"]

  lifecycle_policy = jsonencode({})

  # OPTIONAL: GitHub environments, to create variables as actions variables in your environments
  # github_environments = ["production"]
}

# One canned lifecycle policies (days)
module "ecr_one_days" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=canned-lifecycle-policies"

  # REQUIRED: Repository configuration
  team_name = var.team_name
  repo_name = var.namespace
  namespace = var.namespace

  # REQUIRED: OIDC providers to configure, either "github", "circleci", or both
  oidc_providers = ["github", "circleci"]

  # REQUIRED: GitHub repositories that push to this container repository
  github_repositories = ["cloud-platform-ecr-oidc-test"]

  canned_lifecycle_policy = {
    count = 5
    type  = "days"
  }

  # OPTIONAL: GitHub environments, to create variables as actions variables in your environments
  # github_environments = ["production"]
}

# One canned lifecycle policies (count)
module "ecr_one_count" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=canned-lifecycle-policies"

  # REQUIRED: Repository configuration
  team_name = var.team_name
  repo_name = var.namespace
  namespace = var.namespace

  # REQUIRED: OIDC providers to configure, either "github", "circleci", or both
  oidc_providers = ["github", "circleci"]

  # REQUIRED: GitHub repositories that push to this container repository
  github_repositories = ["cloud-platform-ecr-oidc-test"]

  canned_lifecycle_policy = {
    count = 5
    type  = "images"
  }

  # OPTIONAL: GitHub environments, to create variables as actions variables in your environments
  # github_environments = ["production"]
}

# Canned lifecycle & custom lifecycle (custom should take precedence)
module "ecr_one_custom" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=canned-lifecycle-policies"

  # REQUIRED: Repository configuration
  team_name = var.team_name
  repo_name = var.namespace
  namespace = var.namespace

  # REQUIRED: OIDC providers to configure, either "github", "circleci", or both
  oidc_providers = ["github", "circleci"]

  # REQUIRED: GitHub repositories that push to this container repository
  github_repositories = ["cloud-platform-ecr-oidc-test"]

  canned_lifecycle_policy = {
    count = 5
    type  = "images"
  }

  lifecycle_policy = jsonencode({})

  # OPTIONAL: GitHub environments, to create variables as actions variables in your environments
  # github_environments = ["production"]
}
