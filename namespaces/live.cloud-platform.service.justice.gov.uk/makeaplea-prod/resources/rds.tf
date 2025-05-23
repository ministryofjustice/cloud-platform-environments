/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

module "dps_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.1.0"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  db_engine_version           = "14"
  rds_family                  = "postgres14"
  allow_minor_version_upgrade = "true"
  db_instance_class           = "db.t4g.micro"
  db_max_allocated_storage    = "500"
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support

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


module "mgw_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.1.0"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  db_engine_version           = "14"
  rds_family                  = "postgres14"
  allow_minor_version_upgrade = "true"
  db_instance_class           = "db.t4g.micro"
  db_max_allocated_storage    = "500"
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "mgw_rds" {
  metadata {
    name      = "mgw-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.mgw_rds.rds_instance_endpoint
    database_name         = module.mgw_rds.database_name
    database_username     = module.mgw_rds.database_username
    database_password     = module.mgw_rds.database_password
    rds_instance_address  = module.mgw_rds.rds_instance_address
    url                   = "postgres://${module.mgw_rds.database_username}:${module.mgw_rds.database_password}@${module.mgw_rds.rds_instance_endpoint}/${module.mgw_rds.database_name}"
  }
}

resource "kubernetes_config_map" "rds_mgw" {
  metadata {
    name      = "mgw-rds-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.mgw_rds.database_name

  }
}