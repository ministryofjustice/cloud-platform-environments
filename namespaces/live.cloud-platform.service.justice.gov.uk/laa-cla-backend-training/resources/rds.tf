/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

module "cla_backend_rds_postgres_11" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.19.0"
  vpc_name      = var.vpc_name
  team_name     = var.team_name
  business-unit = var.business_unit
  application   = var.application
  is-production = var.is_production
  namespace     = var.namespace

  db_name = "cla_backend"
  # change the postgres version as you see fit.
  db_engine_version      = "11"
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure_support

  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11
  # Pick the one that defines the postgres version the best
  rds_family = "postgres11"

  # Some engines can't apply some parameters without a reboot(ex postgres9.x cant apply force_ssl immediate).
  # You will need to specify "pending-reboot" here, as default is set to "immediate".


  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "false"

  db_parameter = [
    {
      name         = "rds.force_ssl"
      value        = "1"
      apply_method = "pending-reboot"
    }
  ]

  snapshot_identifier = "manual-backup-1679001807"
  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

module "cla_backend_rds_postgres_11_replica" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.19.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure_support

  # It is mandatory to set the below values to create read replica instance
  db_name = null # "db_name": conflicts with replicate_source_db

  # Set the db_identifier of the source db
  replicate_source_db = module.cla_backend_rds_postgres_11.db_identifier

  # Set to true. No backups or snapshots are created for read replica
  skip_final_snapshot        = "true"
  db_backup_retention_period = 0

  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11
  # Pick the one that defines the postgres version the best
  rds_family        = "postgres11"
  db_engine_version = "11"

  snapshot_identifier = "manual-backup-1679001807"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "cla_backend_rds_postgres_11" {
  metadata {
    name      = "database-11"
    namespace = var.namespace
  }

  data = {
    endpoint          = module.cla_backend_rds_postgres_11.rds_instance_endpoint
    host              = module.cla_backend_rds_postgres_11.rds_instance_address
    port              = module.cla_backend_rds_postgres_11.rds_instance_port
    name              = module.cla_backend_rds_postgres_11.database_name
    user              = module.cla_backend_rds_postgres_11.database_username
    password          = module.cla_backend_rds_postgres_11.database_password
    access_key_id     = module.cla_backend_rds_postgres_11.access_key_id
    secret_access_key = module.cla_backend_rds_postgres_11.secret_access_key
    db_identifier     = module.cla_backend_rds_postgres_11.db_identifier
    replica_host      = module.cla_backend_rds_postgres_11_replica.rds_instance_address
    replica_endpoint  = module.cla_backend_rds_postgres_11_replica.rds_instance_endpoint
  }
}
