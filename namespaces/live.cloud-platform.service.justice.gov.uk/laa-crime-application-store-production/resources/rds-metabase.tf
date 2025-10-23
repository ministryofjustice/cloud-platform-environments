/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "rds_metabase" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = false
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  db_allocated_storage         = "20"
  deletion_protection          = true
  # enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "17.5"
  rds_family        = "postgres17"
  db_instance_class = "db.t4g.micro"

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "kubernetes_secret" "rds_metabase" {
  metadata {
    name      = "rds-metabase-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_metabase.rds_instance_endpoint
    database_name         = module.rds_metabase.database_name
    database_username     = module.rds_metabase.database_username
    database_password     = module.rds_metabase.database_password
    rds_instance_address  = module.rds_metabase.rds_instance_address
    jdbc_url = "jdbc:postgresql://${module.rds_metabase.rds_instance_endpoint}/${module.rds_metabase.database_name}?user=${module.rds_metabase.database_username}&password=${module.rds_metabase.database_password}"
  }
  /* You can replace all of the above with the following, if you prefer to
   * use a single database URL value in your application code:
   *
   * url = "postgres://${module.rds_metabase.database_username}:${module.rds_metabase.database_password}@${module.rds_metabase.rds_instance_endpoint}/${module.rds_metabase.database_name}"
   *
   */
}


# Configmap to store non-sensitive data related to the RDS instance

resource "kubernetes_config_map" "rds_metabase" {
  metadata {
    name      = "rds-metabase-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds_metabase.database_name
    db_identifier = module.rds_metabase.db_identifier
  }
}
