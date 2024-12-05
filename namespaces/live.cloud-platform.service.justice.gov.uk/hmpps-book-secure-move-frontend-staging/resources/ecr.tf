module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  repo_name = var.repo_name

  github_repositories = ["hmpps-book-secure-move-frontend"]

  # enable the oidc implementation for GitHub
  oidc_providers = ["github"]

  # set this if you use one GitHub repository to push to multiple container repositories
  # this ensures the variable key used in the workflow is unique
  github_actions_prefix = "staging"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "book-a-secure-move" # also used for naming the container repository
  namespace              = var.namespace        # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-hmpps-book-secure-move-frontend"
    namespace = var.namespace
  }

  data = {
    repo_url = module.ecr-repo.repo_url
  }
}
