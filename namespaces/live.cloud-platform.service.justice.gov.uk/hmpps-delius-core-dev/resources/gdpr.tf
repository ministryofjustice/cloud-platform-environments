module "gdpr_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  db_name = "gdpr"

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = 1500
  db_allocated_storage         = 200
  enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # PostgreSQL specifics
  db_engine                 = "postgres"
  prepare_for_major_upgrade = false
  db_engine_version         = "16"
  rds_family                = "postgres16"
  db_instance_class         = "db.t4g.medium"

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "kubernetes_secret" "gdpr_rds_instance_output" {
  metadata {
    name      = "gdpr-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    RDS_INSTANCE_ENDPOINT   = module.gdpr_rds.rds_instance_endpoint
    RDS_INSTANCE_IDENTIFIER = module.gdpr_rds.db_identifier
    DATABASE_NAME           = module.gdpr_rds.database_name
    DATABASE_USERNAME       = module.gdpr_rds.database_username
    DATABASE_PASSWORD       = module.gdpr_rds.database_password
    RDS_INSTANCE_ADDRESS    = module.gdpr_rds.rds_instance_address
    RDS_JDBC_URL            = "jdbc:postgresql://${module.gdpr_rds.rds_instance_endpoint}/${module.gdpr_rds.database_name}"
  }
}
