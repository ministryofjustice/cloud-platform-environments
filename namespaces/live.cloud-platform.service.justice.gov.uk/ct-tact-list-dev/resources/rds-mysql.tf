/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
*/
module "rds_mysql" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.17.1"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  # enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # MySQL specifics
  db_engine         = "mysql"
  db_engine_version = "8.0.32"
  rds_family        = "mysql8.0"
  db_instance_class = "db.t4g.micro"
  db_parameter      = []

  # Tags
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "kubernetes_secret" "rds_mysql" {
  metadata {
    name      = "rds-mysql-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_mysql.rds_instance_endpoint
    database_name         = module.rds_mysql.database_name
    database_username     = module.rds_mysql.database_username
    database_password     = module.rds_mysql.database_password
    rds_instance_address  = module.rds_mysql.rds_instance_address
    access_key_id         = module.rds_mysql.access_key_id
    secret_access_key     = module.rds_mysql.secret_access_key
  }
}

resource "kubernetes_config_map" "rds_mysql" {
  metadata {
    name      = "rds-mysql-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds_mysql.database_name
    db_identifier = module.rds_mysql.db_identifier
  }
}
