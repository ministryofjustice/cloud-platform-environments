module "hmpps-ems-ecr" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.3"
  repo_name = "hmpps-ems"
  team_name = "hmpps-ems-platform-team"
}

resource "kubernetes_secret" "hmpps-ems-ecr" {
  metadata {
    name      = "hmpps-ems-ecr"
    namespace = "hmpps-ems-prod"
  }

  data = {
    repo_url          = module.hmpps-ems-ecr.repo_url
    access_key_id     = module.hmpps-ems-ecr.access_key_id
    secret_access_key = module.hmpps-ems-ecr.secret_access_key
  }
}
