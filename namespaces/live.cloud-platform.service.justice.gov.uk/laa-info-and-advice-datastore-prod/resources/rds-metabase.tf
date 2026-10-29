# ---------------------------------------------------------------------------
# Dedicated RDS instance for Metabase's own application/metadata store
# (dashboards, saved questions, users, permissions, connection configs).
#
# This is intentionally a separate instance from the main product database
# (module.rds in rds-postgres.tf) to keep Metabase's blast radius isolated
# from client data - if this instance is compromised or misconfigured, no
# client PII is exposed, since it only ever stores Metabase's own state.
#
# Metabase itself connects to the sanitised mi_reporting views on the main
# instance using the mi_reporting_metabase login defined in rds-postgres.tf.
# This instance is unrelated to that - it is purely Metabase's backing store,
# following the same pattern used by cla_backend's metabase RDS instance.
# ---------------------------------------------------------------------------

module "rds_metabase" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  vpc_name = var.vpc_name
  rds_name = "laa-info-and-advice-datastore-prod-metabase"

  # Engine
  db_engine         = "postgres"
  db_engine_version = "18.6"
  rds_family        = "postgres18"

  # Instance sizing - small/fixed, Metabase's own metadata store is tiny.
  # gp3 (module default storage_type) requires a minimum of 20 GiB allocated.
  db_instance_class        = "db.t4g.micro"
  db_allocated_storage     = "20"
  db_max_allocated_storage = "100"

  # Upgrades
  allow_minor_version_upgrade = true
  allow_major_version_upgrade = false

  # Rotate the master password (bump this date whenever rotation is required)
  db_password_rotated_date = "2026-09-29"

  # Cost optimisation (not for prod)
  enable_rds_auto_start_stop = var.is_production ? false : true

  # Production safeguards
  deletion_protection = "true"

  # Observability
  performance_insights_enabled = false

  # Tags (required by platform)
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "kubernetes_secret" "rds_metabase" {
  metadata {
    name      = "rds-postgresql-instance-metabase-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_metabase.rds_instance_endpoint
    rds_instance_address  = module.rds_metabase.rds_instance_address
    database_name         = module.rds_metabase.database_name
    database_username     = module.rds_metabase.database_username
    database_password     = module.rds_metabase.database_password

    # postgres://user:password@host:port/dbname
    url = "postgres://${module.rds_metabase.database_username}:${module.rds_metabase.database_password}@${module.rds_metabase.rds_instance_endpoint}/${module.rds_metabase.database_name}"

    # For MB_DB_CONNECTION_URI: jdbc:postgresql://host:port/dbname?user=user&password=password
    jdbc_url = "jdbc:postgresql://${module.rds_metabase.rds_instance_endpoint}/${module.rds_metabase.database_name}?user=${module.rds_metabase.database_username}&password=${module.rds_metabase.database_password}"
  }
}
