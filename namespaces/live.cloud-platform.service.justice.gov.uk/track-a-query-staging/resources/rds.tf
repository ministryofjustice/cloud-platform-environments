################################################################################
# Track a Query (Correspondence Tool Staff)
# Application RDS (PostgreSQL)
#################################################################################

module "track_a_query_rds" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  db_allocated_storage       = 30
  storage_type               = "io1"
  db_iops                    = 3000
  vpc_name                   = var.vpc_name
  team_name                  = var.team_name
  business_unit              = var.business_unit
  application                = var.application
  is_production              = var.is_production
  namespace                  = var.namespace
  db_instance_class          = "db.r6g.large"
  db_max_allocated_storage   = "10000"
  db_engine                  = "postgres"
  rds_family                 = "postgres16"
  db_engine_version          = "16.8"
  db_backup_retention_period = "7"
  db_name                    = "track_a_query_staging"
  environment_name           = var.environment
  infrastructure_support     = var.infrastructure_support
  backup_window              = "06:00-08:00"
  enable_rds_auto_start_stop = true
  prepare_for_major_upgrade  = false

  providers = {
    aws = aws.london
  }


  enable_irsa = true
}

resource "kubernetes_secret" "track_a_query_rds" {
  metadata {
    name      = "track-a-query-rds-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.track_a_query_rds.rds_instance_endpoint
    database_name         = module.track_a_query_rds.database_name
    database_username     = module.track_a_query_rds.database_username
    database_password     = module.track_a_query_rds.database_password
    rds_instance_address  = module.track_a_query_rds.rds_instance_address


    url = "postgres://${module.track_a_query_rds.database_username}:${module.track_a_query_rds.database_password}@${module.track_a_query_rds.rds_instance_endpoint}/${module.track_a_query_rds.database_name}"
  }
}
