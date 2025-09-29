module "rds_alfresco" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"

  # VPC configuration
  vpc_name = var.vpc_name

  db_name = "alfresco"

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  db_allocated_storage         = "200"
  # enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # PostgreSQL specifics
  db_engine                 = "postgres"
  prepare_for_major_upgrade = false
  db_engine_version         = "14.17"
  rds_family                = "postgres14"
  db_instance_class         = "db.t3.micro"

  db_backup_retention_period = "28"
  backup_window              = "02:00-04:00"

  # Tagst
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  enable_irsa = true
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

# This places a secret for this PoC RDS instance in the dev namespace,
# which can then be used by a kubernetes job to refresh PoC data.
resource "kubernetes_secret" "rds_refresh" {
  metadata {
    name      = "rds-instance-output-poc"
    namespace = "hmpps-delius-alfresco-dev"
  }

  data = {
    RDS_INSTANCE_ENDPOINT = module.rds_alfresco.rds_instance_endpoint
    DATABASE_NAME         = module.rds_alfresco.database_name
    DATABASE_USERNAME     = module.rds_alfresco.database_username
    DATABASE_PASSWORD     = module.rds_alfresco.database_password
    RDS_INSTANCE_ADDRESS  = module.rds_alfresco.rds_instance_address
  }
}
