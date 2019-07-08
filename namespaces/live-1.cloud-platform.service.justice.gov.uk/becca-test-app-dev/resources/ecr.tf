module "becca_test_app_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"
  repo_name = "becca-test-app"
  team_name = "tactical-products"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "becca_test_app_ecr_credentials" {
  metadata {
    name      = "becca-test-app-ecr-credentials-output"
    namespace = "becca-test-app-dev"
  }

  data {
    access_key_id     = "${module.becca_test_app_ecr_credentials.access_key_id}"
    secret_access_key = "${module.becca_test_app_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.becca_test_app_ecr_credentials.repo_arn}"
    repo_url          = "${module.becca_test_app_ecr_credentials.repo_url}"
  }
}
