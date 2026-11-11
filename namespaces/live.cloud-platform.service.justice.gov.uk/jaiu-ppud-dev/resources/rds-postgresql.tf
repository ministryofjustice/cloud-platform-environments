module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  vpc_name = var.vpc_name

  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_allocated_storage         = 32
  db_max_allocated_storage     = "500"
  db_backup_retention_period   = "7"
  deletion_protection          = "false"
  skip_final_snapshot          = "false"

  db_engine         = "postgres"
  db_engine_version = "16"
  rds_family        = "postgres16"
  db_instance_class = "db.t4g.small"
  storage_type      = "gp3"
  db_name           = "ppud"
  db_parameter = [
    {
      name         = "rds.force_ssl"
      value        = "1"
      apply_method = "immediate"
    }
  ]

  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "random_password" "ppud_app" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "database_administrator" {
  metadata {
    name      = "ppud-database-administrator"
    namespace = var.namespace
  }

  data = {
    username          = module.rds.database_username
    password          = module.rds.database_password
    host              = module.rds.rds_instance_address
    database_name     = module.rds.database_name
    connection_string = "postgresql://${urlencode(module.rds.database_username)}:${urlencode(module.rds.database_password)}@${module.rds.rds_instance_address}:${module.rds.rds_instance_port}/${urlencode(module.rds.database_name)}"
  }
}

resource "kubernetes_secret" "database_runtime" {
  metadata {
    name      = "ppud-database-runtime"
    namespace = var.namespace
  }

  data = {
    username          = "ppud_app"
    password          = random_password.ppud_app.result
    connection_string = "postgresql://${urlencode("ppud_app")}:${urlencode(random_password.ppud_app.result)}@${module.rds.rds_instance_address}:${module.rds.rds_instance_port}/${urlencode(module.rds.database_name)}"
  }
}
