module "rds" {
  source                       = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.18.0"
  vpc_name                     = var.vpc_name
  team_name                    = var.team_name
  business-unit                = var.business_unit
  application                  = var.application
  is-production                = var.is_production
  environment-name             = var.environment
  infrastructure-support       = var.infrastructure_support
  namespace                    = var.namespace
  performance_insights_enabled = true
  db_engine_version            = "14"
  db_instance_class            = "db.t3.small"
  rds_family                   = "postgres14"
  allow_major_version_upgrade  = "false"

  providers = {
    aws = aws.london
  }
}

module "read_replica" {
  count  = 0
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.18.0"

  vpc_name               = var.vpc_name
  application            = var.application
  environment-name       = var.environment
  is-production          = var.is_production
  infrastructure-support = var.infrastructure_support
  team_name              = var.team_name
  db_name                = null # "db_name": conflicts with replicate_source_db
  replicate_source_db    = module.rds.db_identifier

  skip_final_snapshot        = "true"
  db_backup_retention_period = 0

  providers = {
    aws = aws.london
  }
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
    access_key_id         = module.rds.access_key_id
    secret_access_key     = module.rds.secret_access_key
    url                   = "jdbc:postgres://${module.rds.database_username}:${module.rds.database_password}@${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
  }
}


resource "kubernetes_secret" "read_replica" {
  count = 0

  metadata {
    name      = "rds-postgresql-read-replica-output"
    namespace = var.namespace
  }
}

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
