module "pg17" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  # enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "17.9" # If you are managing minor version updates, refer to user guide: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/deploying-an-app/relational-databases/upgrade.html#upgrading-a-database-version-or-changing-the-instance-type
  rds_family        = "postgres17"
  db_instance_class = "db.t4g.micro"
  rds_name          = "demo-dan1-pg17"

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  # Testing RDS Restore
  deletion_protection = false

  # If you want to assign AWS permissions to a k8s pod in your namespace - ie service pod for CLI queries,
  # uncomment below:

  enable_irsa = true

  # If you want to enable Cloudwatch logging for this postgres RDS instance, uncomment the code below:
  # opt_in_xsiam_logging = true
}

resource "kubernetes_secret" "pg17" {
  metadata {
    name      = "rds-postgresql-instance-pg17-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.pg17.rds_instance_endpoint
    database_name         = module.pg17.database_name
    database_username     = module.pg17.database_username
    database_password     = module.pg17.database_password
    rds_instance_address  = module.pg17.rds_instance_address
  }
}

resource "kubernetes_config_map" "pg17" {
  metadata {
    name      = "rds-postgresql-instance-pg17-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.pg17.database_name
    db_identifier = module.pg17.db_identifier
  }
}
