################################################################################
# WP L&D App
# Application RDS (MySQL)
#################################################################################

module "wplearndev_rds" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.0"
  cluster_name               = var.cluster_name
  cluster_state_bucket       = var.cluster_state_bucket
  team_name                  = "cloud-platform"
  business-unit              = "Central Digital"
  application                = "wplearndev"
  is-production              = "false"
  db_engine                  = "mysql"
  db_engine_version          = "5.7.19"
  db_backup_retention_period = "7"
  db_name                    = "wordpress"
  environment-name           = "development"
  infrastructure-support     = "cloud-platform@digital.justice.gov.uk"

  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11
  # Pick the one that defines the postgres version the best
  rds_family = "mysql5.7"

  # Some engines can't apply some parameters without a reboot(ex postgres9.x cant apply force_ssl immediate).
  # You will need to specify "pending-reboot" here, as default is set to "immediate".
  apply_method = "pending-reboot"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "true"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "wplearndev_rds" {
  metadata {
    name      = "wplearndev-rds-output"
    namespace = "wplearndev"
  }

  data = {
    rds_instance_endpoint = module.wplearndev_rds.rds_instance_endpoint
    database_name         = module.wplearndev_rds.database_name
    database_username     = module.wplearndev_rds.database_username
    database_password     = module.wplearndev_rds.database_password
    rds_instance_address  = module.wplearndev_rds.rds_instance_address

    access_key_id     = module.wplearndev_rds.access_key_id
    secret_access_key = module.wplearndev_rds.secret_access_key

    #url = "mysql://${module.wplearndev_rds.database_username}:${module.wplearndev_rds.database_password}@${module.wplearndev_rds.rds_instance_endpoint}/${module.wplearndev_rds.database_name}"
  }
}

