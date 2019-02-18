terraform {
  backend "s3" {}
}

module "offender-risk-profiler-ecr-repo" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.0"
  repo_name = "offender-risk-profiler"
  team_name = "omic"
}

resource "kubernetes_secret" "offender-risk-profiler-ecr-repo" {
  metadata {
    name      = "offender-risk-profiler-ecr-repo"
    namespace = "categorisation-tool-dev"
  }

  data {
    repo_url          = "${module.offender-risk-profiler-ecr-repo.repo_url}"
    access_key_id     = "${module.offender-risk-profiler-ecr-repo.access_key_id}"
    secret_access_key = "${module.offender-risk-profiler-ecr-repo.secret_access_key}"
  }
}
