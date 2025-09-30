module "rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  rds_family                  = "postgres16"
  db_engine_version           = "16.8"
  # db instance class
  db_instance_class           = "db.t4g.small"
  allow_major_version_upgrade = "false"

  # enable performance insights
  performance_insights_enabled = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    rds_instance_address  = module.rds.rds_instance_address
    url                   = "postgres://${module.rds.database_username}:${module.rds.database_password}@${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
  }
}


#module "rds_replica" {
#  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
#  vpc_name               = var.vpc_name
#  team_name              = var.team_name
#  business_unit          = var.business_unit
#  application            = var.application
#  is_production          = var.is_production
#  namespace              = var.namespace
#  environment_name       = var.environment
#  infrastructure_support = var.infrastructure_support
#
#  rds_family                  = "postgres16"
#  db_engine_version           = "16.1"
#  db_instance_class           = "db.t4g.small"
#  allow_major_version_upgrade = "false"
#  db_max_allocated_storage    = "10"
#
#  db_name             = null # "db_name": conflicts with replicate_source_db
#  replicate_source_db = module.rds.db_identifier
#
#  # Set to true for replica database. No backups or snapshots are created for read replica
#  skip_final_snapshot        = "true"
#  db_backup_retention_period = 0
#
#  providers = {
#    aws = aws.london
#  }
#}
#
#resource "kubernetes_secret" "rds_replica" {
#  metadata {
#    name      = "rds-replica-output"
#    namespace = var.namespace
#  }
#
#  data = {
#    rds_instance_endpoint = module.rds_replica.rds_instance_endpoint
#    rds_instance_address  = module.rds_replica.rds_instance_address
#    database_name         = module.rds_replica.database_name
#    database_username     = module.rds_replica.database_username
#    database_password     = module.rds_replica.database_password
#    url                   = "postgres://${module.rds_replica.database_username}:${module.rds_replica.database_password}@${module.rds_replica.rds_instance_endpoint}/${module.rds_replica.database_name}"
#
#  }
#}
