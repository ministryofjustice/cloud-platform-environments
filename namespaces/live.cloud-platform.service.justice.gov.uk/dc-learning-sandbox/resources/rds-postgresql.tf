module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  storage_type         = "gp3"
  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  prepare_for_major_upgrade    = false
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_allocated_storage         = "100"
  db_max_allocated_storage     = "2000"
  enable_rds_auto_start_stop   = true # Turns off database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  deletion_protection          = false

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "17.11"
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

# Secret to store JDBC connection details to use
resource "kubernetes_secret" "rds-spring-datasource" {
  metadata {
    name      = "rds-spring-datasource"
    namespace = var.namespace
  }

  data = {
    SPRING_DATASOURCE_PASSWORD = module.rds.database_password
    SPRING_DATASOURCE_URL = "jdbc:postgresql://${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
    SPRING_DATASOURCE_USERNAME = module.rds.database_username
  }
}
