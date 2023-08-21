
module "grafana_rds" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.19.0"
  vpc_name      = var.vpc_name
  team_name     = var.team_name
  business-unit = var.business_unit
  application   = var.application
  is-production = var.is_production
  namespace     = var.namespace

  # enable performance insights
  performance_insights_enabled = true

  # change the postgres version as you see fit.
  db_engine_version      = "14"
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11
  # Pick the one that defines the postgres version the best
  rds_family = "postgres14"

  db_instance_class = "db.t3.small"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "true"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "grafana_rds" {
  metadata {
    name      = "grafana-rds-instance"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.grafana_rds.rds_instance_endpoint
    database_name         = module.grafana_rds.database_name
    database_username     = module.grafana_rds.database_username
    database_password     = module.grafana_rds.database_password
    rds_instance_address  = module.grafana_rds.rds_instance_address
    access_key_id         = module.grafana_rds.access_key_id
    secret_access_key     = module.grafana_rds.secret_access_key
  }
  /* You can replace all of the above with the following, if you prefer to
     * use a single database URL value in your application code:
     *
     * url = "postgres://${module.grafana_rds.database_username}:${module.grafana_rds.database_password}@${module.grafana_rds.rds_instance_endpoint}/${module.grafana_rds.database_name}"
     *
     */
}

resource "kubernetes_config_map" "grafana_rds" {
  metadata {
    name      = "grafana-rds-instance"
    namespace = var.namespace
  }

  data = {
    database_name = module.grafana_rds.database_name
    db_identifier = module.grafana_rds.db_identifier

  }
}
