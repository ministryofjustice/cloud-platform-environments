module "dps_rds" {
  source                    = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=7.2.0"
  vpc_name                  = var.vpc_name
  team_name                 = var.team_name
  business_unit             = var.business_unit
  application               = var.application
  is_production             = var.is_production
  namespace                 = var.namespace
  environment_name          = var.environment-name
  infrastructure_support    = var.infrastructure_support
  db_instance_class         = "db.r6g.xlarge"
  db_allocated_storage      = "512"
  deletion_protection       = true
  prepare_for_major_upgrade = false
  rds_family                = "postgres16"
  db_engine                 = "postgres"
  db_engine_version         = "16"
  performance_insights_enabled  = true

}

resource "kubernetes_secret" "dps_rds" {
  metadata {
    name      = "dps-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.dps_rds.rds_instance_endpoint
    database_name         = module.dps_rds.database_name
    database_username     = module.dps_rds.database_username
    database_password     = module.dps_rds.database_password
    rds_instance_address  = module.dps_rds.rds_instance_address
    url                   = "postgres://${module.dps_rds.database_username}:${module.dps_rds.database_password}@${module.dps_rds.rds_instance_endpoint}/${module.dps_rds.database_name}"
  }
}
