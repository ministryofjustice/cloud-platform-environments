module "hmcts_mock_api_rds_instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"

  vpc_name               = var.vpc_name
  team_name              = "laa-crime-apps-team"
  business_unit          = "Crime Apps"
  application            = "hmcts-common-platform-mock-api"
  is_production          = "false"
  namespace              = var.namespace
  db_engine_version      = "14"
  environment_name       = "development"
  infrastructure_support = "laa@digital.justice.gov.uk"
  rds_family             = "postgres14"

  allow_major_version_upgrade = "true"
  db_instance_class           = "db.t3.small"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmcts_mock_api_rds_instance" {
  metadata {
    name      = "rds-instance-output"
    namespace = "hmcts-mock-api-dev"
  }

  data = {
    database_name         = module.hmcts_mock_api_rds_instance.database_name
    database_username     = module.hmcts_mock_api_rds_instance.database_username
    rds_instance_address  = module.hmcts_mock_api_rds_instance.rds_instance_address
    rds_instance_endpoint = module.hmcts_mock_api_rds_instance.rds_instance_endpoint
    url                   = "postgres://${module.hmcts_mock_api_rds_instance.database_username}:${module.hmcts_mock_api_rds_instance.database_password}@${module.hmcts_mock_api_rds_instance.rds_instance_endpoint}/${module.hmcts_mock_api_rds_instance.database_name}"
  }
}
