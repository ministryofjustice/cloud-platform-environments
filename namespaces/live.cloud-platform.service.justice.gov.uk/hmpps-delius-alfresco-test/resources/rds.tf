module "rds_alfresco" {
  source       = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.1.0"
  storage_type = "gp2"

  # VPC configuration
  vpc_name = var.vpc_name

  db_name = "alfresco"

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  db_allocated_storage         = 200
  # enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # PostgreSQL specifics
  db_engine                 = "postgres"
  prepare_for_major_upgrade = false
  db_engine_version         = "14.13"
  rds_family                = "postgres14"
  db_instance_class         = "db.t4g.micro"

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
    RDS_INSTANCE_ENDPOINT = module.rds_alfresco.rds_instance_endpoint
    DATABASE_NAME         = module.rds_alfresco.database_name
    DATABASE_USERNAME     = module.rds_alfresco.database_username
    DATABASE_PASSWORD     = module.rds_alfresco.database_password
    RDS_INSTANCE_ADDRESS  = module.rds_alfresco.rds_instance_address
    RDS_JDBC_URL          = "jdbc:postgresql://${module.rds_alfresco.rds_instance_endpoint}/${module.rds_alfresco.database_name}"
  }
}
