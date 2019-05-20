terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "probation_services_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"
  repo_name = "court-probation"
  team_name = "probation-services"
}

resource "kubernetes_secret" "probation_services_ecr_credentials" {
  metadata {
    name      = "probation-services-ecr-credentials-output"
    namespace = "court-probation-dev"
  }

  data {
    access_key_id     = "${module.probation_services_ecr_credentials.access_key_id}"
    secret_access_key = "${module.probation_services_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.probation_services_ecr_credentials.repo_arn}"
    repo_url          = "${module.probation_services_ecr_credentials.repo_url}"
  }
}

module "ps_cps_pack_parser_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"
  repo_name = "cps-pack-parser"
  team_name = "probation-services"
}

resource "kubernetes_secret" "ps_cps_pack_parser_ecr_credentials" {
  metadata {
    name      = "ps_cps_pack_parser_ecr_credentials-output"
    namespace = "court-probation-dev"
  }

  data {
    access_key_id     = "${module.ps_cps_pack_parser_ecr_credentials.access_key_id}"
    secret_access_key = "${module.ps_cps_pack_parser_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.ps_cps_pack_parser_ecr_credentials.repo_arn}"
    repo_url          = "${module.ps_cps_pack_parser_ecr_credentials.repo_url}"
  }
}
