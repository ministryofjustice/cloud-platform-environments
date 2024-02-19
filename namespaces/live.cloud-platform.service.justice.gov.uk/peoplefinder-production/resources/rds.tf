################################################################################
# Peoplefinder
# Application RDS (PostgreSQL)
#################################################################################

module "peoplefinder_rds" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name                   = var.vpc_name
  team_name                  = var.team_name
  business_unit              = var.business_unit
  application                = var.application
  is_production              = var.is_production
  namespace                  = var.namespace
  db_instance_class          = "db.t4g.small"
  db_max_allocated_storage   = "10000"
  db_engine                  = "postgres"
  db_engine_version          = "12"
  db_backup_retention_period = "7"
  db_name                    = "peoplefinder_production"
  environment_name           = var.environment
  infrastructure_support     = var.infrastructure_support

  rds_family = "postgres12"

  # Some engines can't apply some parameters without a reboot(ex postgres9.x cant apply force_ssl immediate).
  # You will need to specify "pending-reboot" here, as default is set to "immediate".


  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "true"

  providers = {
    aws = aws.london
  }
}

module "peoplefinder_rds_replica" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"

  vpc_name = var.vpc_name

  application              = var.application
  environment_name         = var.environment
  is_production            = var.is_production
  infrastructure_support   = var.infrastructure_support
  team_name                = var.team_name
  db_instance_class        = "db.t4g.small"
  db_max_allocated_storage = "10000"
  rds_family               = "postgres12"
  db_engine_version        = "12"
  namespace                = var.namespace
  business_unit            = var.business_unit

  db_name             = null # "db_name": conflicts with replicate_source_db
  replicate_source_db = module.peoplefinder_rds.db_identifier

  # Set to true for replica database. No backups or snapshots are created for read replica
  skip_final_snapshot        = "true"
  db_backup_retention_period = 0

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

resource "kubernetes_secret" "peoplefinder_rds_replica" {
  metadata {
    name      = "peoplefinder-rds-replica-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.peoplefinder_rds_replica.rds_instance_endpoint
    rds_instance_address  = module.peoplefinder_rds_replica.rds_instance_address

    url = "postgres://${module.peoplefinder_rds.database_username}:${module.peoplefinder_rds.database_password}@${module.peoplefinder_rds_replica.rds_instance_endpoint}/${module.peoplefinder_rds.database_name}"
  }
}
