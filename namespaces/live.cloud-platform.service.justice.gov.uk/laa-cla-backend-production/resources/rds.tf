/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

# IMP NOTE: Updating to module version 5.3, existing database password will be rotated.
# Make sure you restart your pods which use this RDS secret to avoid any down time.


module "cla_backend_rds_postgres_10" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.12"
  vpc_name      = var.vpc_name
  team_name     = var.team_name
  business-unit = var.business-unit
  application   = var.application
  is-production = var.is-production
  namespace     = var.namespace

  db_name = "cla_backend"
  # Settings from current setup
  db_instance_class        = "db.m4.4xlarge"
  db_allocated_storage     = "1000"
  db_iops                  = "3000"
  db_max_allocated_storage = "1100"

  # change the postgres version as you see fit.
  db_engine_version      = "10"
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support

  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11
  # Pick the one that defines the postgres version the best
  rds_family = "postgres10"

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


  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

module "cla_backend_rds_postgres_10_replica" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.12"

  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  namespace              = var.namespace


  # Settings from current setup
  db_instance_class        = "db.m4.4xlarge"
  db_allocated_storage     = "1000"
  db_iops                  = "3000"
  db_max_allocated_storage = "1100"

  # change the postgres version as you see fit.
  db_engine_version = "10"

  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11
  # Pick the one that defines the postgres version the best
  rds_family = "postgres10"
  # It is mandatory to set the below values to create read replica instance

  # Set the database_name of the source db
  db_name = module.cla_backend_rds_postgres_10.database_name

  # Set the db_identifier of the source db
  replicate_source_db = module.cla_backend_rds_postgres_10.db_identifier

  # Set to true. No backups or snapshots are created for read replica
  skip_final_snapshot        = "true"
  db_backup_retention_period = 0

  db_parameter = [
    { name = "max_standby_archive_delay", value = "3600000", apply_method = "immediate" },
    { name = "max_standby_streaming_delay", value = "3600000", apply_method = "immediate" },
    { name = "log_statement", value = "all", apply_method = "immediate" }
  ]
  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }

}

module "cla_backend_rds_postgres_11_replica" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.12"

  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  namespace              = var.namespace


  # Settings from current setup
  db_instance_class        = "db.m4.4xlarge"
  db_allocated_storage     = "1000"
  db_iops                  = "3000"
  db_max_allocated_storage = "1100"

  # change the postgres version as you see fit.
  db_engine_version = "11"

  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11
  # Pick the one that defines the postgres version the best
  rds_family = "postgres11"
  # It is mandatory to set the below values to create read replica instance

  # Set the database_name of the source db
  db_name = module.cla_backend_rds_postgres_11.database_name

  # Set the db_identifier of the source db
  replicate_source_db = module.cla_backend_rds_postgres_11.db_identifier

  # Set to true. No backups or snapshots are created for read replica
  skip_final_snapshot        = "true"
  db_backup_retention_period = 0

  db_parameter = [
    { name = "max_standby_archive_delay", value = "3600000", apply_method = "immediate" },
    { name = "max_standby_streaming_delay", value = "3600000", apply_method = "immediate" },
    { name = "log_statement", value = "all", apply_method = "immediate" }
  ]
  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }

}

module "cla_backend_rds_postgres_11" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.12"
  vpc_name      = var.vpc_name
  team_name     = var.team_name
  business-unit = var.business-unit
  application   = var.application
  is-production = var.is-production
  namespace     = var.namespace

  db_name = "cla_backend"
  # Settings from current setup
  db_instance_class        = "db.m4.4xlarge"
  db_allocated_storage     = "1000"
  db_iops                  = "3000"
  db_max_allocated_storage = "1100"

  # change the postgres version as you see fit.
  db_engine_version      = "11"
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support

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


  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "cla_backend_rds_postgres_10" {
  metadata {
    name      = "database-10"
    namespace = var.namespace
  }

  data = {
    endpoint          = module.cla_backend_rds_postgres_10.rds_instance_endpoint
    host              = module.cla_backend_rds_postgres_10.rds_instance_address
    port              = module.cla_backend_rds_postgres_10.rds_instance_port
    name              = module.cla_backend_rds_postgres_10.database_name
    user              = module.cla_backend_rds_postgres_10.database_username
    password          = module.cla_backend_rds_postgres_10.database_password
    replica_host      = module.cla_backend_rds_postgres_10_replica.rds_instance_address
    replica_endpoint  = module.cla_backend_rds_postgres_10_replica.rds_instance_endpoint
    access_key_id     = module.cla_backend_rds_postgres_10.access_key_id
    secret_access_key = module.cla_backend_rds_postgres_10.secret_access_key
    db_identifier     = module.cla_backend_rds_postgres_10.db_identifier
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
    replica_host      = module.cla_backend_rds_postgres_11_replica.rds_instance_address
    replica_endpoint  = module.cla_backend_rds_postgres_11_replica.rds_instance_endpoint
    access_key_id     = module.cla_backend_rds_postgres_11.access_key_id
    secret_access_key = module.cla_backend_rds_postgres_11.secret_access_key
    db_identifier     = module.cla_backend_rds_postgres_11.db_identifier
  }

}
