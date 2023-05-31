/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

module "dps_rds" {
  source                    = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.18.0"
  vpc_name                  = var.vpc_name
  team_name                 = var.team_name
  business-unit             = var.business_unit
  application               = var.application
  is-production             = var.is_production
  namespace                 = var.namespace
  prepare_for_major_upgrade = true
  db_engine_version         = "12.9"
  environment-name          = var.environment
  infrastructure-support    = var.infrastructure_support

  rds_family = "postgres12"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "dps_rds" {
  metadata {
    name      = "dps-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.dps_rds.rds_instance_endpoint
    database_name         = module.dps_rds.database_name
    database_username     = module.dps_rds.database_username
    database_password     = module.dps_rds.database_password
    rds_instance_address  = module.dps_rds.rds_instance_address
    access_key_id         = module.dps_rds.access_key_id
    secret_access_key     = module.dps_rds.secret_access_key
    url                   = "postgres://${module.dps_rds.database_username}:${module.dps_rds.database_password}@${module.dps_rds.rds_instance_endpoint}/${module.dps_rds.database_name}"
  }
}


# Configmap to store non-sensitive data related to the RDS instance

resource "kubernetes_config_map" "rds" {
  metadata {
    name      = "rds-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.dps_rds.database_name

  }
}
