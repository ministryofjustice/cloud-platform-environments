module "drupal_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  db_allocated_storage   = 10
  storage_type           = "gp2"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  # This is the normal setting for staging.
  db_instance_class = "db.t4g.large"

  # This setting is to flex staging up to match production.
  # This should only be used when setting staging up for load testing, so it accurately
  # matches production and therefore is an accurate prediction of prod behaviour.
  #  db_instance_class      = "db.t4g.xlarge"

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
