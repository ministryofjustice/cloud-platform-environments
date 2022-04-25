module "nomis_migration_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.10"
  cluster_name                = var.cluster_name
  team_name                   = var.team_name
  business-unit               = var.business_unit
  application                 = var.application
  is-production               = var.is_production
  namespace                   = var.namespace
  environment-name            = var.environment
  infrastructure-support      = var.infrastructure_support
  rds_family                  = "postgres14"
  allow_major_version_upgrade = "false"
  db_instance_class           = "db.t3.small"
  db_engine_version           = "14"

  providers = {
    aws = aws.london
  }
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
    access_key_id         = module.nomis_migration_rds.access_key_id
    secret_access_key     = module.nomis_migration_rds.secret_access_key
    url                   = "postgres://${module.nomis_migration_rds.database_username}:${module.nomis_migration_rds.database_password}@${module.nomis_migration_rds.rds_instance_endpoint}/${module.nomis_migration_rds.database_name}"
  }
}

