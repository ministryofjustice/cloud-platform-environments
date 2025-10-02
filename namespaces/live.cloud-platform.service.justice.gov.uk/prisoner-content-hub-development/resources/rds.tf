module "drupal_rds" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
  db_allocated_storage       = 10
  storage_type               = "gp2"
  vpc_name                   = var.vpc_name
  team_name                  = var.team_name
  business_unit              = var.business_unit
  application                = var.application
    is_production              = var.is_production
  namespace                  = var.namespace
  environment_name           = var.environment-name
  infrastructure_support     = var.infrastructure_support
  db_instance_class          = "db.t4g.medium"
  enable_rds_auto_start_stop = true
  performance_insights_enabled = true

  snapshot_identifier = "rds:cloud-platform-2703fa2c8a00ad83-2020-10-16-04-52"

  db_engine                = "mariadb"
  db_engine_version        = "10.11"
  rds_family               = "mariadb10.11"
  db_password_rotated_date = "2023-03-22"

  # The recommended transaction isolation level for Drupal is READ-COMMITTED.
  # See https://www.drupal.org/docs/getting-started/system-requirements/setting-the-mysql-transaction-isolation-level
  db_parameter = [
    {
      name         = "tx_isolation"
      value        = "READ-COMMITTED"
      apply_method = "immediate"
    }

  ]

  enable_irsa = true
}

resource "kubernetes_secret" "drupal_rds" {
  metadata {
    name      = "drupal-rds"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.drupal_rds.rds_instance_endpoint
    database_name         = module.drupal_rds.database_name
    database_username     = module.drupal_rds.database_username
    database_password     = module.drupal_rds.database_password
    rds_instance_address  = module.drupal_rds.rds_instance_address

    # This may be a nicer way to represent the DB URL, but I don't _think_ we use it
    # url                   = "postgres://${module.drupal_rds.database_username}:${module.drupal_rds.database_password}@${module.drupal_rds.rds_instance_endpoint}/${module.drupal_rds.database_name}"
  }
}

# This places a secret for this dev RDS instance in the production namespace,
# this can then be used by a kubernetes job which will refresh the dev data.
resource "kubernetes_secret" "drupal_rds_refresh_creds_development" {
  metadata {
    name      = "drupal-rds-instance-output-development"
    namespace = "prisoner-content-hub-production"
  }

  data = {
    rds_instance_endpoint = module.drupal_rds.rds_instance_endpoint
    database_name         = module.drupal_rds.database_name
    database_username     = module.drupal_rds.database_username
    database_password     = module.drupal_rds.database_password
    rds_instance_address  = module.drupal_rds.rds_instance_address
  }
}
