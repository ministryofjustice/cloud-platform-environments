module "ecr-datasette-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.1"

  team_name = var.team_name
  repo_name = var.repo_name

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-datasette-repo" {
  metadata {
    name      = "ecr-datasette-repo-hmpps-book-secure-move-api"
    namespace = var.namespace
  }

  data = {
    repo_url          = module.ecr-datasette-repo.repo_url
    access_key_id     = module.ecr-datasette-repo.access_key_id
    secret_access_key = module.ecr-datasette-repo.secret_access_key
  }
}
