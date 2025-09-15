# module "rds_mariadb" {
#   source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=enable-rds-cloudwatch-logs"

#   # VPC configuration
#   vpc_name = var.vpc_name

#   # RDS configuration
#   allow_minor_version_upgrade  = true
#   allow_major_version_upgrade  = false
#   performance_insights_enabled = false
#   db_max_allocated_storage     = "500"
#   enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
#   # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

#   # MariaDB specifics
#   db_engine         = "mariadb"
#   db_engine_version = "10.6.18"
#   rds_family        = "mariadb10.6"
#   db_instance_class = "db.t4g.micro"
#   db_parameter      = []

#   # Tags
#   application            = var.application
#   business_unit          = var.business_unit
#   environment_name       = var.environment
#   infrastructure_support = var.infrastructure_support
#   is_production          = var.is_production
#   namespace              = var.namespace
#   team_name              = var.team_name

#   # IRSA
# #   enable_irsa = true
# }

# resource "kubernetes_secret" "rds_mariadb" {
#   metadata {
#     name      = "irsa-test-rds-mariadb-instance-output"
#     namespace = var.namespace
#   }

#   data = {
#     rds_instance_endpoint = module.rds_mariadb.rds_instance_endpoint
#     database_username     = module.rds_mariadb.database_username
#     database_password     = module.rds_mariadb.database_password
#     rds_instance_address  = module.rds_mariadb.rds_instance_address
#   }
# }

module "rds_postgres" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=enable-rds-cloudwatch-logs"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # postgres specifics
  db_engine         = "postgres"
  db_engine_version = "16.8"
  rds_family        = "postgres16"
  db_instance_class = "db.t4g.large"
  db_parameter      = []

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  # IRSA
  #   enable_irsa = true
}

resource "kubernetes_secret" "rds_postgres" {
  metadata {
    name      = "irsa-test-rds-postgres-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_postgres.rds_instance_endpoint
    database_username     = module.rds_postgres.database_username
    database_password     = module.rds_postgres.database_password
    rds_instance_address  = module.rds_postgres.rds_instance_address
  }
}