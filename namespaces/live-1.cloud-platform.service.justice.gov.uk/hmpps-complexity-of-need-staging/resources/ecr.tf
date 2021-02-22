module "ecr-repo-complexity-of-need" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.3"

  team_name = var.team_name
  repo_name = "hmpps-complexity-of-need"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-complexity-of-need" {
  metadata {
    name      = "ecr-repo-complexity-of-need"
    namespace = "hmpps-complexity-of-need-staging"
  }

  data = {
    repo_url          = module.ecr-repo-complexity-of-need.repo_url
    access_key_id     = module.ecr-repo-complexity-of-need.access_key_id
    secret_access_key = module.ecr-repo-complexity-of-need.secret_access_key
  }
}

