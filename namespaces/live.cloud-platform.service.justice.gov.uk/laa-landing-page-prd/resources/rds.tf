module "rds" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  db_allocated_storage = 10
  storage_type         = "gp2"

  # VPC configuration
  vpc_name = var.vpc_name

  # Turn off over night
  enable_rds_auto_start_stop = false

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "100"
  db_backup_retention_period   = "35"
  deletion_protection          = true
  enable_irsa = true

  # RDS logging
  opt_in_xsiam_logging  = true

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "16"
  rds_family        = "postgres16"
  db_instance_class = "db.t4g.medium"

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

# resource "kubernetes_secret" "rds-api" {
#   metadata {
#     name      = "rds-postgresql-instance-output"
#     namespace = var.namespace-api
#   }

#   data = {
#     rds_instance_endpoint = module.rds.rds_instance_endpoint
#     database_name         = module.rds.database_name
#     database_username     = module.rds.database_username
#     database_password     = module.rds.database_password
#     rds_instance_address  = module.rds.rds_instance_address
#   }
# }

# ---------------------------------------------------------------------------
# Read-only user for the main RDS instance (module.rds)
# ---------------------------------------------------------------------------

provider "postgresql" {
  host             = module.rds.rds_instance_address
  port             = module.rds.rds_instance_port
  database         = module.rds.database_name
  username         = module.rds.database_username
  password         = module.rds.database_password
  expected_version = "16"
  sslmode          = "require"
  superuser        = false
  connect_timeout  = 15
}

resource "random_password" "readonly_password" {
  length  = 16
  special = false

  keepers = {
    last_changed = "2026-09-02"
  }
}

resource "postgresql_role" "readonly" {
  name     = "laa_landing_page_readonly"
  login    = true
  password = random_password.readonly_password.result

  lifecycle {
    ignore_changes = [roles]
  }
}

# Read every current and future table/schema in the database.
resource "postgresql_grant_role" "readonly_pg_read_all_data" {
  role       = postgresql_role.readonly.name
  grant_role = "pg_read_all_data"
}

# Ensure the role can connect to the database.
resource "postgresql_grant" "readonly_connect" {
  database    = module.rds.database_name
  role        = postgresql_role.readonly.name
  object_type = "database"
  privileges  = ["CONNECT"]
}

resource "kubernetes_secret" "rds_readonly" {
  metadata {
    name      = "rds-postgresql-instance-readonly-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = postgresql_role.readonly.name
    database_password     = random_password.readonly_password.result
    rds_instance_address  = module.rds.rds_instance_address
  }
}

# resource "kubernetes_secret" "rds_readonly_api" {
#   metadata {
#     name      = "rds-postgresql-instance-readonly-output"
#     namespace = var.namespace-api
#   }

#   data = {
#     rds_instance_endpoint = module.rds.rds_instance_endpoint
#     database_name         = module.rds.database_name
#     database_username     = postgresql_role.readonly.name
#     database_password     = random_password.readonly_password.result
#     rds_instance_address  = module.rds.rds_instance_address
#   }
# }

# ---------------------------------------------------------------------------
# Restricted runtime (DML-only) user for the main RDS instance (module.rds).
# The RDS master user (module.rds.database_username) remains the schema owner
# and continues to run Liquibase migrations; this role is for the app's own
# JPA/Hibernate connection only.
# ---------------------------------------------------------------------------

resource "random_password" "app_password" {
  length  = 24
  special = false

  keepers = {
    last_changed = "2026-09-02"
  }
}

resource "postgresql_role" "app" {
  name     = "laa_landing_page_app"
  login    = true
  password = random_password.app_password.result

  lifecycle {
    ignore_changes = [roles]
  }
}

resource "postgresql_grant" "app_connect" {
  database    = module.rds.database_name
  role        = postgresql_role.app.name
  object_type = "database"
  privileges  = ["CONNECT"]
}

resource "postgresql_grant" "app_schema_usage" {
  database    = module.rds.database_name
  role        = postgresql_role.app.name
  schema      = "public"
  object_type = "schema"
  privileges  = ["USAGE"]
}

# Existing tables/sequences created by the master user.
resource "postgresql_grant" "app_tables" {
  database    = module.rds.database_name
  role        = postgresql_role.app.name
  schema      = "public"
  object_type = "table"
  objects     = []
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}

resource "postgresql_grant" "app_sequences" {
  database    = module.rds.database_name
  role        = postgresql_role.app.name
  schema      = "public"
  object_type = "sequence"
  objects     = []
  privileges  = ["USAGE", "SELECT"]
}

# Future tables/sequences created by the master user in later migrations.
resource "postgresql_default_privileges" "app_future_tables" {
  database    = module.rds.database_name
  role        = postgresql_role.app.name
  owner       = module.rds.database_username
  schema      = "public"
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}

resource "postgresql_default_privileges" "app_future_sequences" {
  database    = module.rds.database_name
  role        = postgresql_role.app.name
  owner       = module.rds.database_username
  schema      = "public"
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT"]
}

resource "kubernetes_secret" "rds_app" {
  metadata {
    name      = "rds-postgresql-instance-app-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = postgresql_role.app.name
    database_password     = random_password.app_password.result
    rds_instance_address  = module.rds.rds_instance_address
  }
}