module "nomis_migration_rds" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
  db_allocated_storage = 10
  storage_type         = "gp2"

  vpc_name                  = var.vpc_name
  team_name                 = var.team_name
  business_unit             = var.business_unit
  application               = var.application
  is_production             = var.is_production
  namespace                 = var.namespace
  environment_name          = var.environment
  infrastructure_support    = var.infrastructure_support
  db_instance_class         = "db.t4g.small"
  db_engine                 = "postgres"
  db_engine_version         = "17"
  rds_family                = "postgres17"
  db_password_rotated_date  = "2023-02-21"
  deletion_protection       = true
  prepare_for_major_upgrade = false
}


resource "kubernetes_secret" "nomis_migration_rds" {
  metadata {
    name      = "rds-database"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.nomis_migration_rds.rds_instance_endpoint
    database_name         = module.nomis_migration_rds.database_name
    database_username     = module.nomis_migration_rds.database_username
    database_password     = module.nomis_migration_rds.database_password
    rds_instance_address  = module.nomis_migration_rds.rds_instance_address
    url                   = "postgres://${module.nomis_migration_rds.database_username}:${module.nomis_migration_rds.database_password}@${module.nomis_migration_rds.rds_instance_endpoint}/${module.nomis_migration_rds.database_name}"
  }
}
