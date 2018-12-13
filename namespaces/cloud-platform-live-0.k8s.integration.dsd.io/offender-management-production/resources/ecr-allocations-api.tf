module "ecr-repo-allocation-api" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.0"

  team_name = "offender-management"
  repo_name = "offender-management-allocation-api"
}

resource "kubernetes_secret" "ecr-repo-allocation-api" {
  metadata {
    name      = "offender-management-allocation-api"
    namespace = "offender-management-production"
  }

  data {
    repo_url          = "${module.ecr-repo-allocation-api.repo_url}"
    access_key_id     = "${module.ecr-repo-allocation-api.access_key_id}"
    secret_access_key = "${module.ecr-repo-allocation-api.secret_access_key}"
  }
}
