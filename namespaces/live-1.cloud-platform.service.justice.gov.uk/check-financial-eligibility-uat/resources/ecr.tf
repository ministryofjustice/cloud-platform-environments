module "ecr-repo-check-financial-eligibility-service" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"

  team_name = "laa-apply-for-legal-aid"
  repo_name = "check-financial-eligibility-service"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "ecr-repo-check-financial-eligibility-service" {
  metadata {
    name      = "ecr-repo-check-financial-eligibility-service"
    namespace = "check-financial-eligibility-uat"
  }

  data {
    repo_url          = "${module.ecr-repo-check-financial-eligibility-service.repo_url}"
    access_key_id     = "${module.ecr-repo-check-financial-eligibility-service.access_key_id}"
    secret_access_key = "${module.ecr-repo-check-financial-eligibility-service.secret_access_key}"
  }
}
