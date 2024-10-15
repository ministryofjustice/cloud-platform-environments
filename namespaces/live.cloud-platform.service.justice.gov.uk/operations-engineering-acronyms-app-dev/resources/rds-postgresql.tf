module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.0.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # Database configuration
  db_engine         = "postgres"
  db_engine_version = "16"   # If you are managing minor version updates, refer to user guide: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/deploying-an-app/relational-databases/upgrade.html#upgrading-a-database-version-or-changing-the-instance-type
  rds_family        = "postgres16"
  db_instance_class = "db.t4g.micro"
  db_max_allocated_storage     = "500"
  allow_minor_version_upgrade  = true


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
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    rds_instance_address  = module.rds.rds_instance_address
  }
}