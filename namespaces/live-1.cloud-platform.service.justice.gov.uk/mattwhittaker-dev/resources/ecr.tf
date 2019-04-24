module "mattwhittaker-dev_ecr_credentials" {
  source     = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.1"
  repo_name  = "mattwhittaker-dev-repo"
  team_name  = "mattwhittaker-dev-team"
  aws_region = "eu-west-2"                                                                     # this overwrite the region from the provider defined above.
}

resource "kubernetes_secret" "mattwhittaker-dev_ecr_credentials" {
  metadata {
    name      = "mattwhittaker-dev-ecr-credentials-output"
    namespace = "mattwhittaker-dev"
  }

  data {
    access_key_id     = "${module.mattwhittaker-dev_ecr_credentials.access_key_id}"
    secret_access_key = "${module.mattwhittaker-dev_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.mattwhittaker-dev_ecr_credentials.repo_arn}"
    repo_url          = "${module.mattwhittaker-dev_ecr_credentials.repo_url}"
  }
}
