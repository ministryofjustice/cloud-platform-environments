module "rds_alfresco" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  db_name = "alfresco"

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false

  # enable performance insights
  performance_insights_enabled = true

  # Storage configuration
  db_max_allocated_storage     = "1500"
  db_allocated_storage         = "200"
  db_iops                      = "12000"
  #db_storage_throughput           = "1000" # This doesn't exist as a variable in the module yet.

  # enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # PostgreSQL specifics
  db_engine                 = "postgres"
  prepare_for_major_upgrade = false
  db_engine_version         = "14.17"
  rds_family                = "postgres14"
  db_instance_class         = "db.m8g.2xlarge"
  deletion_protection       = true

  db_parameter = [
    {
      name         = "max_wal_size"
      value        = "2048"          # MB (2GB)
      apply_method = "immediate"
    },
    {
      name         = "checkpoint_timeout"
      value        = "300"            # seconds (5 min)
      apply_method = "immediate"
    },
    {
      name         = "max_parallel_maintenance_workers"
      value        = "6"
      apply_method = "immediate"
    },
    { 
      name         = "maintenance_work_mem", 
      value        = "1048576", # kB = 1GB
      apply_method = "immediate" 
    },
    {
      name         = "rds.force_ssl"
      value        = "1"
      apply_method = "immediate"
    }
  ]

  db_backup_retention_period = "28"
  backup_window              = "02:00-04:00"

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    RDS_INSTANCE_ENDPOINT   = module.rds_alfresco.rds_instance_endpoint
    RDS_INSTANCE_IDENTIFIER = module.rds_alfresco.db_identifier
    DATABASE_NAME           = module.rds_alfresco.database_name
    DATABASE_USERNAME       = module.rds_alfresco.database_username
    DATABASE_PASSWORD       = module.rds_alfresco.database_password
    RDS_INSTANCE_ADDRESS    = module.rds_alfresco.rds_instance_address
    RDS_JDBC_URL            = "jdbc:postgresql://${module.rds_alfresco.rds_instance_endpoint}/${module.rds_alfresco.database_name}"
  }
}

# Configmap to store non-sensitive data related to the RDS instance
resource "kubernetes_config_map" "rds" {
  metadata {
    name      = "rds-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    RDS_INSTANCE_IDENTIFIER = module.rds_alfresco.db_identifier
    DATABASE_NAME           = module.rds_alfresco.database_name
  }
}