################################################################################
# Peoplefinder
# Application RDS (PostgreSQL)
#################################################################################

module "peoplefinder_rds" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.18.0"
  vpc_name                   = var.vpc_name
  team_name                  = var.team_name
  business-unit              = var.business_unit
  application                = var.application
  is-production              = var.is_production
  namespace                  = var.namespace
  environment-name           = var.environment
  infrastructure-support     = var.infrastructure_support
  db_engine                  = "postgres"
  db_engine_version          = "12"
  db_backup_retention_period = "7"
  db_name                    = "peoplefinder_development"
  enable_rds_auto_start_stop = true

  rds_family = "postgres12"

  # Some engines can't apply some parameters without a reboot(ex postgres9.x cant apply force_ssl immediate).
  # You will need to specify "pending-reboot" here, as default is set to "immediate".


  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "true"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "peoplefinder_rds" {
  metadata {
    name      = "peoplefinder-rds-output"
    namespace = "peoplefinder-development"
  }

  data = {
    rds_instance_endpoint = module.peoplefinder_rds.rds_instance_endpoint
    database_name         = module.peoplefinder_rds.database_name
    database_username     = module.peoplefinder_rds.database_username
    database_password     = module.peoplefinder_rds.database_password
    rds_instance_address  = module.peoplefinder_rds.rds_instance_address

    access_key_id     = module.peoplefinder_rds.access_key_id
    secret_access_key = module.peoplefinder_rds.secret_access_key

    url = "postgres://${module.peoplefinder_rds.database_username}:${module.peoplefinder_rds.database_password}@${module.peoplefinder_rds.rds_instance_endpoint}/${module.peoplefinder_rds.database_name}"
  }
}

