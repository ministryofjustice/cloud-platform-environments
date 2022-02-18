module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.6"

  team_name = var.team_name
  repo_name = var.repo_name

  providers = {
    aws = aws.london
  }
}

module "it-healthcheck-ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.6"

  team_name = var.team_name
  repo_name = var.repo_name

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "it-healthcheck-ecr-repo" {
  metadata {
    name      = "it-healthcheck-ecr-repo"
    namespace = var.namespace
  }

  data = {
    repo_url          = module.it-healthcheck-ecr-repo.repo_url
    access_key_id     = module.it-healthcheck-ecr-repo.access_key_id
    secret_access_key = module.it-healthcheck-ecr-repo.secret_access_key
    arn               = module.it-healthcheck-ecr-repo.repo_arn
  }
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-laa-cla-public"
    namespace = var.namespace
  }

  data = {
    repo_url          = module.ecr-repo.repo_url
    access_key_id     = module.ecr-repo.access_key_id
    secret_access_key = module.ecr-repo.secret_access_key
    arn               = module.ecr-repo.repo_arn
  }
}
