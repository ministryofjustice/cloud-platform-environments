module "court_case_service_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  namespace                   = var.namespace
  application                 = var.application
  environment_name            = var.environment-name
  infrastructure_support      = var.infrastructure_support
  is_production               = var.is_production
  prepare_for_major_upgrade   = true
  allow_major_version_upgrade = true
  db_engine                   = "postgres"
  db_engine_version           = "14.9"
  db_instance_class           = "db.t4g.xlarge"
  rds_family                  = "postgres14"
  db_allocated_storage        = "35"
  enable_rds_auto_start_stop  = true

  snapshot_identifier = "court-case-service-manual-snapshot-1670251827"

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
