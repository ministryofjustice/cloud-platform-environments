
module "remand-and-sentencing-api-rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.19.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "14.7"
  rds_family        = "postgres14"
  db_instance_class = "db.t4g.small"

  # Tags
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
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
