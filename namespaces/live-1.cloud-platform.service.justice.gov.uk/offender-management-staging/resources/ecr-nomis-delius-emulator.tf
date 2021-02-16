module "ecr-repo-nomis-delius-emulator" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.3"

  team_name = var.team_name
  repo_name = "nomis-delius-emulator"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-nomis-delius-emulator" {
  metadata {
    name      = "ecr-repo-nomis-delius-emulator"
    namespace = "offender-management-staging"
  }

  data = {
    repo_url          = module.ecr-repo-nomis-delius-emulator.repo_url
    access_key_id     = module.ecr-repo-nomis-delius-emulator.access_key_id
    secret_access_key = module.ecr-repo-nomis-delius-emulator.secret_access_key
  }
}

