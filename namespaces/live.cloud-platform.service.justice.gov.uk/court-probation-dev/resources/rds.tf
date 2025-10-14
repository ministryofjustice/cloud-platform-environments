module "court_case_service_rds" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
  db_allocated_storage       = 10
  storage_type               = "gp2"
  vpc_name                   = var.vpc_name
  team_name                  = var.team_name
  business_unit              = var.business_unit
  namespace                  = var.namespace
  application                = var.application
  environment_name           = var.environment-name
  infrastructure_support     = var.infrastructure_support
  is_production              = var.is_production
  prepare_for_major_upgrade  = false
  rds_family                 = var.rds-family
  db_engine                  = var.db_engine
  db_engine_version          = var.db_engine_version
  db_instance_class          = var.db_instance_class
  enable_rds_auto_start_stop = true
  db_password_rotated_date   = "2025-10-14"

  providers = {
    aws = aws.london
  }


  enable_irsa = true
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
