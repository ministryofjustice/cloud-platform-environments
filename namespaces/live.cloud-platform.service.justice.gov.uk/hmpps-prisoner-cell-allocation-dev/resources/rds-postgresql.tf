/*
 * Postgres for hmpps-change-someones-cell-api, which takes over cell move orchestration from
 * whereabouts-api. An RDS instance previously existed in this namespace for the retired
 * hmpps-prisoner-cell-allocation-api and was removed in 14b0db32ab (MAP-1366); this largely
 * restores it.
 *
 * Make sure that you use the latest version of the module by changing the `ref=` value in the
 * `source` attribute to the latest version listed on the releases page of this repository.
 */
module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  enable_rds_auto_start_stop   = true

  # PostgreSQL specifics
  db_engine                 = "postgres"
  db_engine_version         = "18"
  rds_family                = "postgres18"
  db_instance_class         = "db.t4g.small"
  prepare_for_major_upgrade = false

  # Tags
  application            = "hmpps-change-someones-cell-api"
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

# Configmap to store non-sensitive data related to the RDS instance
resource "kubernetes_config_map" "rds" {
  metadata {
    name      = "rds-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds.database_name
    db_identifier = module.rds.db_identifier
  }
}
