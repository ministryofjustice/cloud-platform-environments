module "court_case_service_rds" {
  source                       = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name                     = var.vpc_name
  team_name                    = var.team_name
  business_unit                = var.business_unit
  application                  = var.application
  is_production                = var.is_production
  namespace                    = var.namespace
  environment_name             = var.environment-name
  infrastructure_support       = var.infrastructure_support
  rds_family                   = var.rds-family
  db_engine                    = "postgres"
  db_engine_version            = var.db_engine_version
  prepare_for_major_upgrade    = false
  allow_major_version_upgrade  = false
  performance_insights_enabled = true
  db_instance_class            = "db.t4g.xlarge"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "court_case_service_rds" {
  metadata {
    name      = "court-case-service-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.court_case_service_rds.rds_instance_endpoint
    database_name         = module.court_case_service_rds.database_name
    database_username     = module.court_case_service_rds.database_username
    database_password     = module.court_case_service_rds.database_password
    rds_instance_address  = module.court_case_service_rds.rds_instance_address
    url                   = "postgres://${module.court_case_service_rds.database_username}:${module.court_case_service_rds.database_password}@${module.court_case_service_rds.rds_instance_endpoint}/${module.court_case_service_rds.database_name}"
  }
}
