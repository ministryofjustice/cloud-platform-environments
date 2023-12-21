module "cemo_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "16"
  rds_family        = "postgres16"
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

resource "kubernetes_secret" "cemo_rds" {
  metadata {
    name      = "rds-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.cemo_rds.rds_instance_endpoint
    database_name         = module.cemo_rds.database_name
    database_username     = module.cemo_rds.database_username
    database_password     = module.cemo_rds.database_password
    rds_instance_address  = module.cemo_rds.rds_instance_address
  }
}

# Configmap to store non-sensitive data related to the RDS instance
resource "kubernetes_config_map" "cemo_rds" {
  metadata {
    name      = "cemo_rds"
    namespace = var.namespace
  }

  data = {
    database_name = module.cemo_rds.database_name
    db_identifier = module.cemo_rds.db_identifier
  }
}
