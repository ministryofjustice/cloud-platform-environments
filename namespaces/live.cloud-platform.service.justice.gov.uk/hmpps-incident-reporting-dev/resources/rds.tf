# Retrieve mp_dps_sg_name SG group ID, CP-MP-INGRESS
data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}

# No read replica in dev: the API no longer uses one and DPR loads from the primary here (IR-1999).
# Only prod has a replica, for DPR.
module "dps_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  enable_rds_auto_start_stop = true

  prepare_for_major_upgrade = false
  db_instance_class           = "db.t4g.small"
  rds_family                  = "postgres18"
  db_engine_version           = "18.6"
  deletion_protection         = true
  allow_major_version_upgrade = "false"
  allow_minor_version_upgrade = "true"

  providers = {
    aws = aws.london
  }

# Add security groups for DPR
  vpc_security_group_ids = [data.aws_security_group.mp_dps_sg.id]

# Add parameters to enable DPR team to configure replication
  db_parameter = [
    {
      # Restated so it is explicit, as for prisoner property and CSRA: our own list replaces the
      # module default. (The postgres18 family already defaults it to 1.)
      # pending-reboot, not immediate: AWS reports a parameter left at its default as
      # pending-reboot, so "immediate" shows as a change on every plan (IR-2033).
      name         = "rds.force_ssl"
      value        = "1"
      apply_method = "pending-reboot"
    },
    {
      name         = "rds.logical_replication"
      value        = "1"
      apply_method = "pending-reboot"
    },
    {
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

  # Creates the IAM policy granting rds:RebootDBInstance on this instance, so the namespace
  # service pod can apply pending-reboot parameters. Cloud Platform do not reboot RDS on
  # request - teams do it from a service pod. See IR-1982.
  enable_irsa = true
}

resource "kubernetes_secret" "dps_rds" {
  metadata {
    name      = "dps-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    db_identifier         = module.dps_rds.db_identifier
    resource_id           = module.dps_rds.resource_id
    rds_instance_endpoint = module.dps_rds.rds_instance_endpoint
    database_name         = module.dps_rds.database_name
    database_username     = module.dps_rds.database_username
    database_password     = module.dps_rds.database_password
    rds_instance_address  = module.dps_rds.rds_instance_address
    url                   = "postgres://${module.dps_rds.database_username}:${module.dps_rds.database_password}@${module.dps_rds.rds_instance_endpoint}/${module.dps_rds.database_name}"
  }
}
