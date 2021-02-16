module "ecr-repo-api" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.3"

  team_name = var.team_name
  repo_name = var.repo_name

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-api" {
  metadata {
    name      = "ecr-repo-laa-legal-adviser-api"
    namespace = "laa-legal-adviser-api-staging"
  }

  data = {
    repo_url          = module.ecr-repo-api.repo_url
    access_key_id     = module.ecr-repo-api.access_key_id
    secret_access_key = module.ecr-repo-api.secret_access_key
  }
}

