module "sentence-planning_ecr" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"
  repo_name = "sentence-planning"
  team_name = "digital-prison-services"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "sentence-planning_ecr" {
  metadata {
    name      = "sentence-planning-ecr-credentials-output"
    namespace = "sentence-planning-development"
  }

  data {
    access_key_id     = "${module.sentence-planning_ecr.access_key_id}"
    secret_access_key = "${module.sentence-planning_ecr.secret_access_key}"
    repo_arn          = "${module.sentence-planning_ecr.repo_arn}"
    repo_url          = "${module.sentence-planning_ecr.repo_url}"
  }
}
