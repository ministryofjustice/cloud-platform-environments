module "hmpps_interventions_postgres14" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.1.0"
  storage_type           = "gp2"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  rds_family                   = "postgres14"
  db_engine_version = "14.17"
  db_instance_class            = "db.m6g.2xlarge"
  db_allocated_storage         = "50"
  allow_major_version_upgrade  = "false"
  performance_insights_enabled = true

  providers = {
    aws = aws.london
  }

}

resource "kubernetes_secret" "hmpps_interventions_postgres14" {
  metadata {
    name      = "postgres14"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps_interventions_postgres14.rds_instance_endpoint
    database_name         = module.hmpps_interventions_postgres14.database_name
    database_username     = module.hmpps_interventions_postgres14.database_username
    database_password     = module.hmpps_interventions_postgres14.database_password
    rds_instance_address  = module.hmpps_interventions_postgres14.rds_instance_address
    url                   = "postgres://${module.hmpps_interventions_postgres14.database_username}:${module.hmpps_interventions_postgres14.database_password}@${module.hmpps_interventions_postgres14.rds_instance_endpoint}/${module.hmpps_interventions_postgres14.database_name}"
  }
}

module "hmpps_interventions_postgres14_replica" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.1.0"
  db_allocated_storage   = 10
  storage_type           = "gp2"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  rds_family                   = "postgres14"
  db_engine_version = "14.17"
  db_instance_class            = "db.m6g.2xlarge"
  allow_major_version_upgrade  = "false"
  db_max_allocated_storage     = "50"
  performance_insights_enabled = true

  replicate_source_db = module.hmpps_interventions_postgres14.db_identifier

  # Set to true for replica database. No backups or snapshots are created for read replica
  skip_final_snapshot        = "true"
  db_backup_retention_period = 0

  providers = {
    aws = aws.london
  }

}

resource "kubernetes_secret" "hmpps_interventions_postgres14_replica" {
  metadata {
    name      = "hmpps-interventions-postgres14-rds-replica-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps_interventions_postgres14_replica.rds_instance_endpoint
    rds_instance_address  = module.hmpps_interventions_postgres14_replica.rds_instance_address
    database_name         = module.hmpps_interventions_postgres14.database_name
    database_username     = module.hmpps_interventions_postgres14.database_username
    database_password     = module.hmpps_interventions_postgres14.database_password
    url                   = "postgres://${module.hmpps_interventions_postgres14.database_username}:${module.hmpps_interventions_postgres14.database_password}@${module.hmpps_interventions_postgres14_replica.rds_instance_endpoint}/${module.hmpps_interventions_postgres14.database_name}"

  }
}
