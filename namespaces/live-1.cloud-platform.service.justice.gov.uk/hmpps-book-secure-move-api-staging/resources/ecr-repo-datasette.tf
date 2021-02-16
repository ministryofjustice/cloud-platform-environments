module "ecr-repo-datasette" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.3"

  team_name = var.team_name
  repo_name = "ecr-repo-datasette"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-datasette" {
  metadata {
    name      = "ecr-repo-hmpps-book-secure-move-datasette"
    namespace = var.namespace
  }

  data = {
    repo_url          = module.ecr-repo-datasette.repo_url
    access_key_id     = module.ecr-repo-datasette.access_key_id
    secret_access_key = module.ecr-repo-datasette.secret_access_key
  }
}
