module "rds-instance-temp" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.6"

  cluster_name         = var.cluster_name
  cluster_state_bucket = var.cluster_state_bucket

  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is-production
  infrastructure-support = var.infrastructure-support
  team_name              = var.team_name

  # enable performance insights
  performance_insights_enabled = true

  providers = {
    aws = aws.london
  }

  db_parameter = [
    {
      name         = "rds.force_ssl"
      value        = "0"
      apply_method = "immediate"
    }
  ]
}

resource "kubernetes_secret" "rds-instance-temp" {
  metadata {
    name      = "rds-instance-temp-hmpps-book-secure-move-api-${var.environment-name}"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.rds-instance-temp.access_key_id
    secret_access_key = module.rds-instance-temp.secret_access_key
    url               = "postgres://${module.rds-instance-temp.database_username}:${module.rds-instance-temp.database_password}@${module.rds-instance-temp.rds_instance_endpoint}/${module.rds-instance-temp.database_name}"
  }
}

module "rds-read-replica-temp" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.6"

  cluster_name         = var.cluster_name
  cluster_state_bucket = var.cluster_state_bucket

  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is-production
  infrastructure-support = var.infrastructure-support
  team_name              = var.team_name

  db_name             = module.rds-instance-temp.database_name
  replicate_source_db = module.rds-instance-temp.db_identifier

  # Set to true for replica database. No backups or snapshots are created for read replica
  skip_final_snapshot        = "true"
  db_backup_retention_period = 0

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }

  db_parameter = [
    {
      name         = "rds.force_ssl"
      value        = "0"
      apply_method = "immediate"
    }
  ]
}


resource "kubernetes_secret" "rds-read-replica-temp" {
  metadata {
    name      = "read-rds-instance-temp-hmpps-book-secure-move-api-${var.environment-name}"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.rds-instance-temp.access_key_id
    secret_access_key = module.rds-instance-temp.secret_access_key
    url               = "postgres://${module.rds-instance-temp.database_username}:${module.rds-instance-temp.database_password}@${module.rds-read-replica-temp.rds_instance_endpoint}/${module.rds-read-replica-temp.database_name}"
  }
}
