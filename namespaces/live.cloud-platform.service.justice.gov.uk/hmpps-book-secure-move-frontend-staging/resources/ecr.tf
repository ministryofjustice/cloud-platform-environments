module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"

  team_name = "book-a-secure-move"
  repo_name = var.repo_name

  github_repositories = ["hmpps-book-secure-move-frontend"]

  # enable the oidc implementation for GitHub
  oidc_providers = ["github"]

  # set this if you use one GitHub repository to push to multiple container repositories
  # this ensures the variable key used in the workflow is unique
  github_actions_prefix = "staging"
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-hmpps-book-secure-move-frontend"
    namespace = var.namespace
  }

  data = {
    repo_url          = module.ecr-repo.repo_url
    access_key_id     = module.ecr-repo.access_key_id
    secret_access_key = module.ecr-repo.secret_access_key
  }
}

