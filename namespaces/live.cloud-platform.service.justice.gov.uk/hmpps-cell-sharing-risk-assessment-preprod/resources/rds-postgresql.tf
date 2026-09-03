/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
# Retrieve mp_dps_sg_name SG group ID, CP-MP-INGRESS. Required so the Data Hub DMS process can
# reach this instance on 5432. MAPA-344.
data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}

module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # PostgreSQL specifics
  db_engine                 = "postgres"
  db_engine_version         = "18" # If you are managing minor version updates, refer to user guide: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/deploying-an-app/relational-databases/upgrade.html#upgrading-a-database-version-or-changing-the-instance-type
  rds_family                = "postgres18"
  db_instance_class         = "db.t4g.small"
  prepare_for_major_upgrade = false

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  # Datahub ingestion (MAPA-344). rds.logical_replication and shared_preload_libraries are
  # pending-reboot, so the instance must be rebooted after this applies before `show wal_level;`
  # reports `logical` and the pglogical extension will install.
  # https://dsdmoj.atlassian.net/wiki/spaces/DPR/pages/4461494352
  db_parameter = [
    {
      # The module's db_parameter default is a single rds.force_ssl entry, and supplying our own list
      # replaces it rather than merging - so this must be restated here or TLS stops being enforced.
      # This instance currently relies on that default, so omitting it would be a live change.
      name         = "rds.force_ssl"
      value        = "1"
      apply_method = "immediate"
    },
    {
      name         = "rds.logical_replication"
      value        = "1"
      apply_method = "pending-reboot"
    },
    {
      # This list replaces the engine default rather than merging with it. Listing only pglogical
      # would silently drop pg_tle and pg_stat_statements. RDS re-adds rdsutils and rds_casts itself,
      # so they do not need listing.
      name         = "shared_preload_libraries"
      value        = "pg_tle,pg_stat_statements,pglogical"
      apply_method = "pending-reboot"
    },
    {
      name         = "max_wal_size"
      value        = "1024"
      apply_method = "immediate"
    },
    {
      name         = "wal_sender_timeout"
      value        = "0"
      apply_method = "immediate"
    },
    {
      name         = "max_slot_wal_keep_size"
      value        = "40000"
      apply_method = "immediate"
    }
  ]

  # Add security group for DPR. This is additive - the module concats it with the instance's own
  # security group - so application connectivity is unaffected.
  vpc_security_group_ids = [data.aws_security_group.mp_dps_sg.id]

  # Creates the IAM policy granting rds:RebootDBInstance on this instance, so the namespace service
  # pod can apply the pending-reboot parameters above. Cloud Platform do not perform RDS reboots on
  # request - teams do them from a service pod. Defaults to false.
  enable_irsa = true

  # If you want to enable Cloudwatch logging for this postgres RDS instance, uncomment the code below:
  # opt_in_xsiam_logging = true
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    db_identifier         = module.rds.db_identifier
    resource_id           = module.rds.resource_id
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    rds_instance_address  = module.rds.rds_instance_address
  }
  /* You can replace all of the above with the following, if you prefer to
     * use a single database URL value in your application code:
     *
     * url = "postgres://${module.rds.database_username}:${module.rds.database_password}@${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
     *
     */
}

# Configmap to store non-sensitive data related to the RDS instance

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
