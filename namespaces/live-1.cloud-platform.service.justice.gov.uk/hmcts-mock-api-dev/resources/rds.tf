variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

module "hmcts_mock_api_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.12"

  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  team_name              = "laa-crime-apps-team"
  business-unit          = "Crime Apps"
  application            = "hmcts-common-platform-mock-api"
  is-production          = "false"
  namespace              = var.namespace
  db_engine_version      = "11"
  environment-name       = "development"
  infrastructure-support = "laa@digital.justice.gov.uk"
  rds_family             = "postgres11"

  allow_major_version_upgrade = "true"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmcts_mock_api_rds" {
  metadata {
    name      = "hmcts-mock-api-instance-output"
    namespace = "hmcts-mock-api-dev"
  }

  data = {
    url = "postgres://${module.hmcts_mock_api_rds.database_username}:${module.hmcts_mock_api_rds.database_password}@${module.hmcts_mock_api_rds.rds_instance_endpoint}/${module.hmcts_mock_api_rds.database_name}"
  }
}

