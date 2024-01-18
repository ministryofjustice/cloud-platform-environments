
module "evidencelibrary_rds" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name      = var.vpc_name
  team_name     = var.team_name
  business_unit = var.business_unit
  application   = var.application
  is_production = var.is_production
  namespace     = var.namespace

  # enable performance insights
  performance_insights_enabled = true

  # change the postgres version as you see fit.
  db_engine_version      = var.db_engine_version
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  # change the instance class as you see fit.
  db_instance_class        = var.db_instance_class
  db_max_allocated_storage = var.db_max_allocated_storage


  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11
  # Pick the one that defines the postgres version the best
  rds_family = var.rds-family

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "true"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "evidencelibrary_rds" {
  metadata {
    name      = "evidencelibrary-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.evidencelibrary_rds.rds_instance_endpoint
    database_name         = module.evidencelibrary_rds.database_name
    database_username     = module.evidencelibrary_rds.database_username
    database_password     = module.evidencelibrary_rds.database_password
    rds_instance_address  = module.evidencelibrary_rds.rds_instance_address
    url                   = "Host=${module.evidencelibrary_rds.rds_instance_address};Port=5432;Database=${module.evidencelibrary_rds.database_name};Username=${module.evidencelibrary_rds.database_username};Password=${module.evidencelibrary_rds.database_password};SSL Mode=Prefer;Trust Server Certificate=true;"
  }
}
