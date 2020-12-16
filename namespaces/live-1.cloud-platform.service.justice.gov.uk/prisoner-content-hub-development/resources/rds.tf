module "drupal_rds" {
  # We need to use at least 5.4, which introduces support for MariaDB by making `custom_parameters` overridable.
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.12"
  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  namespace              = var.namespace
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support

  snapshot_identifier = "rds:cloud-platform-2703fa2c8a00ad83-2020-10-16-04-52"

  db_engine         = "mariadb"
  db_engine_version = "10.4"
  rds_family        = "mariadb10.4"

  # We need to explicitly set this to an empty list, otherwise the module
  # will add `rds.force_ssl`, which MariaDB doesn't support
  db_parameter = []
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
    access_key_id         = module.drupal_rds.access_key_id
    secret_access_key     = module.drupal_rds.secret_access_key

    # This may be a nicer way to represent the DB URL, but I don't _think_ we use it
    # url                   = "postgres://${module.drupal_rds.database_username}:${module.drupal_rds.database_password}@${module.drupal_rds.rds_instance_endpoint}/${module.drupal_rds.database_name}"
  }
}
