module "court_data_adaptor_rds" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.0"
  vpc_name      = var.vpc_name
  namespace     = var.namespace
  team_name     = "laa-crime-apps-team"
  business_unit = "Crime Apps"
  application   = "laa-court-data-adaptor"
  is_production = "false"

  db_engine_version      = "14"
  environment_name       = "test"
  infrastructure_support = var.infrastructure_support
  rds_family             = "postgres14"

  allow_major_version_upgrade = "true"
  enable_rds_auto_start_stop  = true
  db_instance_class           = "db.t4g.micro"
  db_max_allocated_storage    = "500"

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
    database_name         = module.court_data_adaptor_rds.database_name
    database_username     = module.court_data_adaptor_rds.database_username
    rds_instance_address  = module.court_data_adaptor_rds.rds_instance_address
    rds_instance_endpoint = module.court_data_adaptor_rds.rds_instance_endpoint
    url                   = "postgres://${module.court_data_adaptor_rds.database_username}:${module.court_data_adaptor_rds.database_password}@${module.court_data_adaptor_rds.rds_instance_endpoint}/${module.court_data_adaptor_rds.database_name}"
  }
}
