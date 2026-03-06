module "rds" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  db_allocated_storage = 10
  storage_type         = "gp2"
  vpc_name             = var.vpc_name
  team_name            = var.team_name
  business_unit        = var.business_unit
  application          = "Complexity of Need microservice"
  is_production        = var.is_production
  namespace            = var.namespace

  # enable performance insights
  performance_insights_enabled = false

  # change the postgres version as you see fit.
  db_instance_class        = "db.t4g.micro"
  db_max_allocated_storage = "500"
  environment_name         = var.environment
  infrastructure_support   = var.infrastructure_support

  db_engine_version           = "15.7"
  rds_family                  = "postgres15"
  allow_minor_version_upgrade = true
  allow_major_version_upgrade = false
  prepare_for_major_upgrade   = false

  enable_rds_auto_start_stop = true # 22:00–06:00 UTC
  maintenance_window         = "sun:19:00-sun:21:00"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }

}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    rds_instance_address  = module.rds.rds_instance_address
  }
  /* You can replace all of the above with the following, if you prefer to
     * use a single database URL value in your application code:
     *
     * url = "postgres://${module.rds.database_username}:${module.rds.database_password}@${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
     *
     */
}

resource "kubernetes_config_map" "rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds.database_name
    db_identifier = module.rds.db_identifier

  }
}

# This places a secret for this preprod RDS instance in the production namespace,
# this can then be used by a kubernetes job which will refresh the preprod data.
resource "kubernetes_secret" "rds_refresh_creds" {
  metadata {
    name      = "rds-instance-output-preprod"
    namespace = "hmpps-complexity-of-need-production"
  }

  data = {
    database_name        = module.rds.database_name
    database_username    = module.rds.database_username
    database_password    = module.rds.database_password
    rds_instance_address = module.rds.rds_instance_address
  }
}
