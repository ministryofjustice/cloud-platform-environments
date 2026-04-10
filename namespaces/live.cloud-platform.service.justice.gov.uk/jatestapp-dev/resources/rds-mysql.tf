/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
*/
module "rds_mysql" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=7.3.0"

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
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  # If you want to assign AWS permissions to a k8s pod in your namespace - ie service pod for CLI queries,
  # uncomment below:

  # enable_irsa = true
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