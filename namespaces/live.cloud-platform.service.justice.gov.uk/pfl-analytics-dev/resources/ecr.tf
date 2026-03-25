module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  repo_name = var.app_repo
  team_name = var.team_name

  github_repositories = [var.app_repo]

  namespace = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr" {
  metadata {
    name      = "ecr-repo-${var.app_repo}"
    namespace = var.namespace
  }

  data = {
    repo_arn          = module.ecr.repo_arn
    repo_url          = module.ecr.repo_url
    access_key_id     = module.ecr.access_key_id
    secret_access_key = module.ecr.secret_access_key
  }
}
