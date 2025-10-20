module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"

  vpc_name = var.vpc_name

  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  enable_rds_auto_start_stop   = true         ### turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date   = "2023-04-17" ### rotate your database password.

  db_engine         = "postgres"
  db_engine_version = "17.5" ### If you are managing minor version updates, refer to user guide: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/deploying-an-app/relational-databases/upgrade.html#upgrading-a-database-version-or-changing-the-instance-type
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

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name         = module.rds.database_name
    database_password     = module.rds.database_password
    database_username     = module.rds.database_username
    db_identifier         = module.rds.db_identifier
    rds_instance_address  = module.rds.rds_instance_address
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    rds_instance_port     = module.rds.rds_instance_port
    # resource_id           = module.rds.resource_id
    # url = "postgres://${module.rds.database_username}:${module.rds.database_password}@${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
  }
}

resource "kubernetes_secret" "rds-spring" {
  metadata {
    name      = "rds-spring"
    namespace = var.namespace
  }

  data = {
    SPRING_DATASOURCE_USERNAME = module.rds.database_username
    SPRING_DATASOURCE_PASSWORD = module.rds.database_password
    SPRING_DATASOURCE_URL = "jdbc:postgresql://${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
  }
}
