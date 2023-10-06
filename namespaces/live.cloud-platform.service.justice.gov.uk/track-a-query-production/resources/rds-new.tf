################################################################################
# Track a Query (Correspondence Tool Staff)
# Application RDS (new) (PostgreSQL)
#################################################################################

module "track_a_query_rds_new" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.0"
  vpc_name                   = var.vpc_name
  team_name                  = var.team_name
  business_unit              = var.business_unit
  application                = var.application
  is_production              = var.is_production
  namespace                  = var.namespace
  environment_name           = var.environment
  infrastructure_support     = var.infrastructure_support
  db_engine                  = "postgres"
  db_engine_version          = "12"
  db_backup_retention_period = "7"
  db_name                    = "track_a_query_production_new"

  rds_family = "postgres12"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "true"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "track_a_query_rds_new" {
  metadata {
    name      = "track-a-query-rds-new-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.track_a_query_rds_new.rds_instance_endpoint
    database_name         = module.track_a_query_rds_new.database_name
    database_username     = module.track_a_query_rds_new.database_username
    database_password     = module.track_a_query_rds_new.database_password
    rds_instance_address  = module.track_a_query_rds_new.rds_instance_address
    url                   = "postgres://${module.track_a_query_rds_new.database_username}:${module.track_a_query_rds_new.database_password}@${module.track_a_query_rds_new.rds_instance_endpoint}/${module.track_a_query_rds_new.database_name}"
  }
}
