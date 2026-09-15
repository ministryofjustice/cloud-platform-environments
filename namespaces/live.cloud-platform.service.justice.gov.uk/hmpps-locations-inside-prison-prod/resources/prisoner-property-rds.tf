# RDS Postgres instance for hmpps-prisoner-property-api.
# Lives in the shared hmpps-locations-inside-prison-<env> namespace alongside the existing
# dps_rds instance. Modelled on the namespace's existing resources/rds.tf.
# NOTE: data.aws_security_group.mp_dps_sg is already declared in the existing rds.tf in this
# folder, so it is reused here (do not redeclare).

module "prisoner_property_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  performance_insights_enabled = true

  db_instance_class           = "db.t4g.large"
  rds_name                    = "hmpps-prisoner-property-api-prod"
  rds_family                  = "postgres18"
  db_engine_version           = "18"
  deletion_protection         = true
  allow_major_version_upgrade = "false"
  allow_minor_version_upgrade = "true"

  providers = {
    aws = aws.london
  }

  # Datahub ingestion (MAPB-763). rds.logical_replication and shared_preload_libraries are
  # pending-reboot, so the instance must be rebooted after this applies before `show wal_level;`
  # reports `logical` and the pglogical extension will install.
  # https://dsdmoj.atlassian.net/wiki/spaces/DPR/pages/4461494352
  db_parameter = [
    {
      # The module's db_parameter default is a single rds.force_ssl entry, and supplying our own list
      # replaces it rather than merging - so this must be restated here or TLS stops being enforced.
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
      # As with rds.force_ssl above, this list replaces the engine default rather than merging
      # with it. Listing only pglogical silently dropped pg_tle and pg_stat_statements, which
      # Performance Insights needs for query-level detail.
      # RDS re-adds rdsutils and rds_casts itself, so they do not need listing.
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

  vpc_security_group_ids = [data.aws_security_group.mp_dps_sg.id]

  # Creates the IAM policy granting rds:RebootDBInstance on this instance, so the namespace
  # service pod can apply the pending-reboot parameters above. Cloud Platform do not perform
  # RDS reboots on request - teams do them from a service pod. Defaults to false. See MAPB-763.
  enable_irsa = true
}

# Read replica for Datahub ingestion (MAPB-763). Datahub's CDC capture reads from here rather than
# the primary, so its reads cannot affect the operational database. Modelled on the dps_rds_replica
# in this folder's rds.tf.
#
# hot_standby_feedback is required on a replica: without it the replica invalidates the replication
# slot the DMS process consumes from.
module "prisoner_property_rds_replica" {
  count  = 1
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  vpc_name = var.vpc_name

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  # Must match the source instance
  db_engine         = "postgres"
  db_engine_version = "18"
  rds_family        = "postgres18"
  db_instance_class = "db.t4g.large"

  # Conflicts with replicate_source_db, so must be null on a replica
  db_name = null

  replicate_source_db = module.prisoner_property_rds.db_identifier

  # No backups or snapshots are taken of a read replica
  skip_final_snapshot        = "true"
  db_backup_retention_period = 0

  db_parameter = [
    {
      # The module's db_parameter default is a single rds.force_ssl entry, and supplying our own list
      # replaces it rather than merging - so this must be restated here or TLS stops being enforced.
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
      # As with rds.force_ssl above, this list replaces the engine default rather than merging
      # with it. Listing only pglogical silently dropped pg_tle and pg_stat_statements, which
      # Performance Insights needs for query-level detail.
      # RDS re-adds rdsutils and rds_casts itself, so they do not need listing.
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
    },
    {
      name         = "hot_standby_feedback"
      value        = "1"
      apply_method = "immediate"
    }
  ]

  providers = {
    aws = aws.london
  }

  vpc_security_group_ids = [data.aws_security_group.mp_dps_sg.id]

  # The policy the module emits is scoped to its own instance ARN, so the replica needs its own
  # enable_irsa - the primary's policy does not cover it. Without this the replica cannot be
  # rebooted, and the replica is the instance Datahub reads from. See MAPB-763.
  enable_irsa = true
}

resource "kubernetes_secret" "prisoner_property_rds" {
  metadata {
    name      = "prisoner-property-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    db_identifier         = module.prisoner_property_rds.db_identifier
    resource_id           = module.prisoner_property_rds.resource_id
    rds_instance_endpoint = module.prisoner_property_rds.rds_instance_endpoint
    database_name         = module.prisoner_property_rds.database_name
    database_username     = module.prisoner_property_rds.database_username
    database_password     = module.prisoner_property_rds.database_password
    rds_instance_address  = module.prisoner_property_rds.rds_instance_address
    url                   = "postgres://${module.prisoner_property_rds.database_username}:${module.prisoner_property_rds.database_password}@${module.prisoner_property_rds.rds_instance_endpoint}/${module.prisoner_property_rds.database_name}"
  }
}

# The replica's credentials and database name are the same as the primary, so only the endpoint is
# published here. Datahub's DMS source endpoint points at this address.
resource "kubernetes_secret" "prisoner_property_rds_replica" {
  count = 1

  metadata {
    name      = "prisoner-property-rds-read-replica-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.prisoner_property_rds_replica[0].rds_instance_endpoint
    rds_instance_address  = module.prisoner_property_rds_replica[0].rds_instance_address
  }
}
