module "rds" {
  source                       = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  db_allocated_storage         = 10
  storage_type                 = "gp2"
  vpc_name                     = var.vpc_name
  team_name                    = var.team_name
  business_unit                = var.business_unit
  application                  = var.application
  is_production                = var.is_production
  environment_name             = var.environment
  infrastructure_support       = var.infrastructure_support
  namespace                    = var.namespace
  performance_insights_enabled = true
  db_instance_class            = "db.t3.xlarge"
  enable_irsa                  = true

  allow_major_version_upgrade  = "true"
  allow_minor_version_upgrade  = "true"
  prepare_for_major_upgrade    = "true"
  db_engine                    = "postgres"
  db_engine_version            = "18.6"
  rds_family                   = "postgres18"

  providers = {
    aws = aws.london
  }

}

module "read_replica" {
  count                = 0
  source               = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  db_allocated_storage = 10
  storage_type         = "gp2"

  vpc_name               = var.vpc_name
  application            = var.application
  environment_name       = var.environment
  is_production          = var.is_production
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  business_unit          = var.business_unit
  namespace              = var.namespace
  db_name                = null # "db_name": conflicts with replicate_source_db
  replicate_source_db    = module.rds.db_identifier

  skip_final_snapshot        = "true"
  db_backup_retention_period = 0

  allow_major_version_upgrade  = "true"
  allow_minor_version_upgrade  = "true"
  prepare_for_major_upgrade    = "true"
  db_engine_version            = "18.6"
  rds_family                   = "postgres18"

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
