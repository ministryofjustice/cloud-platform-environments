module "rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.16"

  vpc_name = var.vpc_name

  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is-production
  namespace              = var.namespace
  infrastructure-support = var.infrastructure-support
  team_name              = var.team_name

  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window

  performance_insights_enabled = true

  db_allocated_storage   = 200
  db_instance_class      = "db.t3.2xlarge"

  db_engine              = "postgres"
  db_engine_version      = "12.11"
  rds_family             = "postgres12"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "false"

  db_parameter = [
    {
      "apply_method" : "immediate",
      "name" : "log_min_duration_statement",
      "value" : "2000"
    }
  ]
}

resource "kubernetes_secret" "rds-instance" {
  metadata {
    name      = "rds-instance-hmpps-book-secure-move-api-${var.environment-name}"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.rds-instance.access_key_id
    secret_access_key = module.rds-instance.secret_access_key
    url               = "postgres://${module.rds-instance.database_username}:${module.rds-instance.database_password}@${module.rds-instance.rds_instance_endpoint}/${module.rds-instance.database_name}"
  }
}

module "rds-read-replica" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.16"

  vpc_name = var.vpc_name

  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is-production
  infrastructure-support = var.infrastructure-support
  team_name              = var.team_name
  db_allocated_storage   = 200
  db_instance_class      = "db.t3.medium"

  db_name             = null # "db_name": conflicts with replicate_source_db
  replicate_source_db = module.rds-instance.db_identifier

  # Set to true for replica database. No backups or snapshots are created for read replica
  skip_final_snapshot        = "true"
  db_backup_retention_period = 0

  db_engine_version = "12.11"
  rds_family        = "postgres12"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}


resource "kubernetes_secret" "rds-read-replica" {
  metadata {
    name      = "read-rds-instance-hmpps-book-secure-move-api-${var.environment-name}"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.rds-read-replica.access_key_id
    secret_access_key = module.rds-read-replica.secret_access_key
    url               = "postgres://${module.rds-instance.database_username}:${module.rds-instance.database_password}@${module.rds-read-replica.rds_instance_endpoint}/${module.rds-read-replica.database_name}"
  }
}
