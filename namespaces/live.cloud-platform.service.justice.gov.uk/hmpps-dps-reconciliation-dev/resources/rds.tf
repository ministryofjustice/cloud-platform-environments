module "hmpps_dps_reconciliation_rds" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  db_allocated_storage       = 20
  storage_type               = "gp3"
  vpc_name                   = var.vpc_name
  team_name                  = var.team_name
  business_unit              = var.business_unit
  application                = var.application
  is_production              = var.is_production
  namespace                  = var.namespace
  environment_name           = var.environment
  infrastructure_support     = var.infrastructure_support
  db_instance_class          = "db.t4g.micro"
  db_engine                  = "postgres"
  db_engine_version          = "18"
  rds_family                 = "postgres18"
  deletion_protection        = true
  prepare_for_major_upgrade  = true
  enable_rds_auto_start_stop = true
  db_max_allocated_storage   = "500"
}

resource "kubernetes_secret" "hmpps_dps_reconciliation_rds" {
  metadata {
    name      = "rds-database"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps_dps_reconciliation_rds.rds_instance_endpoint
    database_name         = module.hmpps_dps_reconciliation_rds.database_name
    database_username     = module.hmpps_dps_reconciliation_rds.database_username
    database_password     = module.hmpps_dps_reconciliation_rds.database_password
    rds_instance_address  = module.hmpps_dps_reconciliation_rds.rds_instance_address
    url                   = "postgres://${module.hmpps_dps_reconciliation_rds.database_username}:${module.hmpps_dps_reconciliation_rds.database_password}@${module.hmpps_dps_reconciliation_rds.rds_instance_endpoint}/${module.hmpps_dps_reconciliation_rds.database_name}"
  }
}
