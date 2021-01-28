################################################################################
# Peoplefinder
# Application RDS (PostgreSQL)
#################################################################################

module "peoplefinder_rds" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.12"
  cluster_name               = var.cluster_name
  cluster_state_bucket       = var.cluster_state_bucket
  team_name                  = "peoplefinder"
  business-unit              = "Central Digital"
  application                = "peoplefinder"
  is-production              = "true"
  namespace                  = var.namespace
  db_engine                  = "postgres"
  db_engine_version          = "12.3"
  db_backup_retention_period = "7"
  db_name                    = "peoplefinder_production"
  environment-name           = "production"
  infrastructure-support     = "people-finder-support@digital.justice.gov.uk"

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
    namespace = "peoplefinder-production"
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
