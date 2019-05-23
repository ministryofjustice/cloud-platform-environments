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
    name      = "ps-cps-pack-parser-ecr-credentials-output"
    namespace = "court-probation-dev"
  }

  data {
    access_key_id     = "${module.ps_cps_pack_parser_ecr_credentials.access_key_id}"
    secret_access_key = "${module.ps_cps_pack_parser_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.ps_cps_pack_parser_ecr_credentials.repo_arn}"
    repo_url          = "${module.ps_cps_pack_parser_ecr_credentials.repo_url}"
  }
}

module "mock_cp_court_service_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"
  repo_name = "mock-cp-court-service"
  team_name = "probation-services"
}

resource "kubernetes_secret" "mock_cp_court_service_ecr_credentials" {
  metadata {
    name      = "mock-cp-court-service-ecr-credentials-output"
    namespace = "court-probation-dev"
  }

  data {
    access_key_id     = "${module.mock_cp_court_service_ecr_credentials.access_key_id}"
    secret_access_key = "${module.mock_cp_court_service_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.mock_cp_court_service_ecr_credentials.repo_arn}"
    repo_url          = "${module.mock_cp_court_service_ecr_credentials.repo_url}"
  }
}

module "court_list_service_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"
  repo_name = "court-list-service"
  team_name = "probation-services"
}

resource "kubernetes_secret" "court_list_service_ecr_credentials" {
  metadata {
    name      = "court-list-service-ecr-credentials-output"
    namespace = "court-probation-dev"
  }

  data {
    access_key_id     = "${module.court_list_service_ecr_credentials.access_key_id}"
    secret_access_key = "${module.court_list_service_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.court_list_service_ecr_credentials.repo_arn}"
    repo_url          = "${module.court_list_service_ecr_credentials.repo_url}"
  }
}
