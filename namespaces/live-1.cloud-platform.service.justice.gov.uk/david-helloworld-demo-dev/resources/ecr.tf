/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "helloworld_ecr_credentials" {
  source     = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.1"
  repo_name  = "hello-world-demo-app"
  team_name  = "cloud-platform"
  aws_region = "eu-west-2"
}

resource "kubernetes_secret" "ecr_credentials" {
  metadata {
    name      = "helloworld-ecr-credentials-output"
    namespace = "david-helloworld-demo-dev"
  }

  data {
    access_key_id     = "${module.helloworld_ecr_credentials.access_key_id}"
    secret_access_key = "${module.helloworld_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.helloworld_ecr_credentials.repo_arn}"
    repo_url          = "${module.helloworld_ecr_credentials.repo_url}"
  }
}
