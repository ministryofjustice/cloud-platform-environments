
module "remand-and-sentencing-api-rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.1.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # PostgreSQL specifics
  prepare_for_major_upgrade = false
  db_engine         = "postgres"
  db_engine_version = "17"
  rds_family        = "postgres17"
  db_instance_class = "db.t4g.medium"
  db_allocated_storage="100"
  db_max_allocated_storage = "500"
  storage_type = "gp3"

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
    rds_instance_endpoint = module.remand-and-sentencing-api-rds.rds_instance_endpoint
    database_name         = module.remand-and-sentencing-api-rds.database_name
    db_identifier         = module.remand-and-sentencing-api-rds.db_identifier
    database_username     = module.remand-and-sentencing-api-rds.database_username
    database_password     = module.remand-and-sentencing-api-rds.database_password
    rds_instance_address  = module.remand-and-sentencing-api-rds.rds_instance_address
  }
  /* You can replace all of the above with the following, if you prefer to
     * use a single database URL value in your application code:
     *
     * url = "postgres://${module.rds.database_username}:${module.rds.database_password}@${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
     *
     */
}
