module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  vpc_name = var.vpc_name

  db_engine                    = "postgres"
  db_engine_version            = "16"
  rds_family                   = "postgres16"
  db_instance_class            = "db.t4g.small"
  db_allocated_storage         = 32
  db_max_allocated_storage     = "500"
  storage_type                 = "gp3"
  db_backup_retention_period   = "7"
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  deletion_protection          = "true"
  skip_final_snapshot          = "false"
  performance_insights_enabled = false
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

resource "kubernetes_secret" "database_admin" {
  metadata {
    name      = "ppud-database-admin"
    namespace = var.namespace
  }

  data = {
    username          = module.rds.database_username
    password          = module.rds.database_password
    connection_string = "postgresql://${urlencode(module.rds.database_username)}:${urlencode(module.rds.database_password)}@${module.rds.rds_instance_address}:5432/${urlencode(module.rds.database_name)}?sslmode=verify-full&sslrootcert=/etc/ssl/certs/rds-ca-bundle.pem"
    database_name     = module.rds.database_name
    database_host     = module.rds.rds_instance_address
  }

  type = "Opaque"
}

resource "kubernetes_secret" "database_runtime" {
  metadata {
    name      = "ppud-database-runtime"
    namespace = var.namespace
  }

  data = {
    username          = "ppud_app"
    password          = random_password.ppud_app.result
    connection_string = "postgresql://${urlencode("ppud_app")}:${urlencode(random_password.ppud_app.result)}@${module.rds.rds_instance_address}:5432/${urlencode(module.rds.database_name)}?sslmode=verify-full&sslrootcert=/etc/ssl/certs/rds-ca-bundle.pem"
  }

  type = "Opaque"
}
