module "sentence-planning-api_ecr" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.3"
  repo_name = "sentence-planning-api"
  team_name = "digital-prison-services"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "sentence-planning-api_ecr" {
  metadata {
    name      = "sentence-planning-api-ecr-credentials-output"
    namespace = "sentence-planning-development"
  }

  data {
    access_key_id     = "${module.sentence-planning-api_ecr.access_key_id}"
    secret_access_key = "${module.sentence-planning-api_ecr.secret_access_key}"
    repo_arn          = "${module.sentence-planning-api_ecr.repo_arn}"
    repo_url          = "${module.sentence-planning-api_ecr.repo_url}"
  }
}
