/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "prometheus_ecr_exporter_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"
  repo_name = "prometheus_ecr_exporter"
  team_name = "cloud-platform"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "prometheus_ecr_exporter_credentials" {
  metadata {
    name      = "prometheus-exporter-ecr-credentials-output"
    namespace = "monitoring"
  }

  data {
    access_key_id     = "${module.prometheus_ecr_exporter_credentials.access_key_id}"
    secret_access_key = "${module.prometheus_ecr_exporter_credentials.secret_access_key}"
    repo_arn          = "${module.prometheus_ecr_exporter_credentials.repo_arn}"
    repo_url          = "${module.prometheus_ecr_exporter_credentials.repo_url}"
  }
}
