module "court_data_adaptor_rds" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.10"
  cluster_name  = var.cluster_name
  namespace     = var.namespace
  team_name     = "laa-crime-apps-team"
  business-unit = "Crime Apps"
  application   = "laa-court-data-adaptor"
  is-production = "false"

  db_engine_version      = "14.2"
  environment-name       = "test"
  infrastructure-support = "laa@digital.justice.gov.uk"
  rds_family             = "postgres14"

  allow_major_version_upgrade = "true"
  db_instance_class           = "db.t3.small"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "court_data_adaptor_rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = "laa-court-data-adaptor-test"
  }

  data = {
    access_key_id         = module.court_data_adaptor_rds.access_key_id
    secret_access_key     = module.court_data_adaptor_rds.secret_access_key
    database_name         = module.court_data_adaptor_rds.database_name
    database_username     = module.court_data_adaptor_rds.database_username
    rds_instance_address  = module.court_data_adaptor_rds.rds_instance_address
    rds_instance_endpoint = module.court_data_adaptor_rds.rds_instance_endpoint
    url                   = "postgres://${module.court_data_adaptor_rds.database_username}:${module.court_data_adaptor_rds.database_password}@${module.court_data_adaptor_rds.rds_instance_endpoint}/${module.court_data_adaptor_rds.database_name}"
  }
}
