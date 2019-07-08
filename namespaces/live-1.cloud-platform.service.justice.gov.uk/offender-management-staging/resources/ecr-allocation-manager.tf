module "ecr-repo-allocation-manager" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"

  team_name = "offender-management"
  repo_name = "offender-management-allocation-manager"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "ecr-repo-allocation-manager" {
  metadata {
    name      = "ecr-repo-allocation-manager"
    namespace = "offender-management-staging"
  }

  data {
    repo_url          = "${module.ecr-repo-allocation-manager.repo_url}"
    access_key_id     = "${module.ecr-repo-allocation-manager.access_key_id}"
    secret_access_key = "${module.ecr-repo-allocation-manager.secret_access_key}"
  }
}
