module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  vpc_name = var.vpc_name
  rds_name = "laa-info-and-advice-datastore-uat"

  # Engine
  db_engine         = "postgres"
  db_engine_version = "18.6"
  rds_family        = "postgres18"

  # Instance sizing
  db_instance_class        = "db.t4g.micro"
  db_max_allocated_storage = "500"

  # Upgrades
  allow_minor_version_upgrade = true
  allow_major_version_upgrade = false

  # Rotate the master password (bump this date whenever rotation is required)
  db_password_rotated_date = "2026-09-24"

  # Cost optimisation (not for prod)
  enable_rds_auto_start_stop = var.is_production ? false : true

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

# ---------------------------------------------------------------------------
# Read-only login for Metabase, restricted to the sanitised mi_reporting
# schema/views (created and permissioned by the app's Flyway migration
# V32__create_mi_reporting_schema.sql, which owns the mi_reporting_reader
# role and its SELECT-only grants). This role is only granted membership of
# mi_reporting_reader, so it inherits exactly those permissions and nothing
# on the public schema (where client PII lives). Terraform owns this login's
# credential/rotation lifecycle independently of the app's migrations, the
# same way the master password rotation works (see db_password_rotated_date
# above and mi_reporting_metabase_rotated_date below).
# ---------------------------------------------------------------------------

provider "postgresql" {
  host             = module.rds.rds_instance_address
  port             = module.rds.rds_instance_port
  database         = module.rds.database_name
  username         = module.rds.database_username
  password         = module.rds.database_password
  expected_version = "18"
  sslmode          = "require"
  superuser        = false
  connect_timeout  = 15
}

resource "random_password" "mi_reporting_metabase_password" {
  length  = 24
  special = false

  keepers = {
    # Bump this date whenever rotation is required.
    mi_reporting_metabase_rotated_date = "2026-09-28"
  }
}

resource "postgresql_role" "mi_reporting_metabase" {
  name     = "mi_reporting_metabase"
  login    = true
  password = random_password.mi_reporting_metabase_password.result

  lifecycle {
    ignore_changes = [roles]
  }
}

resource "postgresql_grant_role" "mi_reporting_metabase_membership" {
  role       = postgresql_role.mi_reporting_metabase.name
  grant_role = "mi_reporting_reader"
}

resource "postgresql_grant" "mi_reporting_metabase_connect" {
  database    = module.rds.database_name
  role        = postgresql_role.mi_reporting_metabase.name
  object_type = "database"
  privileges  = ["CONNECT"]
}

resource "kubernetes_secret" "rds_mi_reporting_metabase" {
  metadata {
    name      = "rds-postgresql-instance-mi-reporting-metabase-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = postgresql_role.mi_reporting_metabase.name
    database_password     = random_password.mi_reporting_metabase_password.result
    rds_instance_address  = module.rds.rds_instance_address
  }
}
