# module "rds_aurora" {
#   source = "github.com/ministryofjustice/cloud-platform-terraform-rds-aurora?ref=enable-rds-aurora-cloudwatch-logs"

#   # VPC configuration
#   vpc_name = var.vpc_name

#   # Database configuration
#   engine         = "aurora-postgresql"
#   engine_version = "15.13"
#   engine_mode    = "provisioned"
#   instance_type  = "db.t4g.medium"
#   replica_count  = 1
#   allow_major_version_upgrade  = true


#   # Tags
#   business_unit          = var.business_unit
#   application            = var.application
#   is_production          = var.is_production
#   team_name              = var.team_name
#   namespace              = var.namespace
#   environment_name       = var.environment
#   infrastructure_support = var.infrastructure_support
# }

# resource "kubernetes_secret" "aurora_db" {
#   metadata {
#     name      = "wajid-test-rds-aurora-cluster-output"
#     namespace = var.namespace
#   }

#   data = {
#     rds_cluster_endpoint        = module.rds_aurora.rds_cluster_endpoint
#     rds_cluster_reader_endpoint = module.rds_aurora.rds_cluster_reader_endpoint
#     db_cluster_identifier       = module.rds_aurora.db_cluster_identifier
#     database_name               = module.rds_aurora.database_name
#     database_username           = module.rds_aurora.database_username
#     database_password           = module.rds_aurora.database_password
#   }
# }

module "rds_mariadb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=enable-rds-cloudwatch-logs"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  # enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # MariaDB specifics
  db_engine         = "mariadb"
  db_engine_version = "10.11"
  rds_family        = "mariadb10.11"
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

resource "kubernetes_secret" "rds_mariadb" {
  metadata {
    name      = "wajid-test-rds-mariadb-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_mariadb.rds_instance_endpoint
    database_username     = module.rds_mariadb.database_username
    database_password     = module.rds_mariadb.database_password
    rds_instance_address  = module.rds_mariadb.rds_instance_address
  }
}

module "rds_mysql" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=enable-rds-cloudwatch-logs"

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
  db_engine_version = "8.0.40"
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
    name      = "wajid-test-rds-mysql-instance-output"
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

module "rds_mssql" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=enable-rds-cloudwatch-logs"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  # enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # SQL Server specifics
  db_engine            = "sqlserver-web"
  db_engine_version    = "16.00.4115.5.v1"
  rds_family           = "sqlserver-web-16.0"
  db_instance_class    = "db.t3.small"
  db_allocated_storage = 32 # minimum of 20GiB for SQL Server

  # Some engines can't apply some parameters without a reboot(ex SQL Server cant apply force_ssl immediate).
  # You will need to specify "pending-reboot" here, as default is set to "immediate".
  db_parameter = [
    {
      name         = "rds.force_ssl"
      value        = "1"
      apply_method = "pending-reboot"
    }
  ]

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

resource "kubernetes_secret" "rds_mssql" {
  metadata {
    name      = "wajid-test-rds-mssql-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_mssql.rds_instance_endpoint
    database_username     = module.rds_mssql.database_username
    database_password     = module.rds_mssql.database_password
    rds_instance_address  = module.rds_mssql.rds_instance_address
  }
}

