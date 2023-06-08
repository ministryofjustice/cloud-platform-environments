module "hmcts_mock_api_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.19.0"

  vpc_name               = var.vpc_name
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
    access_key_id         = module.hmcts_mock_api_rds.access_key_id
    secret_access_key     = module.hmcts_mock_api_rds.secret_access_key
    database_name         = module.hmcts_mock_api_rds.database_name
    database_username     = module.hmcts_mock_api_rds.database_username
    rds_instance_address  = module.hmcts_mock_api_rds.rds_instance_address
    rds_instance_endpoint = module.hmcts_mock_api_rds.rds_instance_endpoint
    url                   = "postgres://${module.hmcts_mock_api_rds.database_username}:${module.hmcts_mock_api_rds.database_password}@${module.hmcts_mock_api_rds.rds_instance_endpoint}/${module.hmcts_mock_api_rds.database_name}"
  }
}
