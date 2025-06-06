################################################################################
# Peoplefinder
# Application RDS (PostgreSQL)
#################################################################################

module "peoplefinder_rds" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.1.0"
  db_allocated_storage       = 10
  storage_type               = "gp2"
  vpc_name                   = var.vpc_name
  team_name                  = var.team_name
  business_unit              = var.business_unit
  application                = var.application
  is_production              = var.is_production
  namespace                  = var.namespace
  environment_name           = var.environment
  infrastructure_support     = var.infrastructure_support
  db_instance_class          = "db.t4g.micro"
  db_max_allocated_storage   = "500"
  db_engine                  = "postgres"
  db_engine_version          = "16"
  rds_family                 = "postgres16"
  db_backup_retention_period = "7"
  db_name                    = "peoplefinder_staging"
  backup_window              = "06:00-08:00"
  enable_rds_auto_start_stop = true

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "false"
  prepare_for_major_upgrade   = "false"

  providers = {
    aws = aws.london
  }

}

resource "kubernetes_secret" "peoplefinder_rds" {
  metadata {
    name      = "peoplefinder-rds-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.peoplefinder_rds.rds_instance_endpoint
    database_name         = module.peoplefinder_rds.database_name
    database_username     = module.peoplefinder_rds.database_username
    database_password     = module.peoplefinder_rds.database_password
    rds_instance_address  = module.peoplefinder_rds.rds_instance_address


    url = "postgres://${module.peoplefinder_rds.database_username}:${module.peoplefinder_rds.database_password}@${module.peoplefinder_rds.rds_instance_endpoint}/${module.peoplefinder_rds.database_name}"
  }
}
