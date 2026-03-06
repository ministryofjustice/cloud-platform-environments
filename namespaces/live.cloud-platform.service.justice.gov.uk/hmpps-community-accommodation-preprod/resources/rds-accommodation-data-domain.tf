module "accommodation_data_domain_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  db_allocated_storage        = 20
  storage_type                = "gp3"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support
  allow_major_version_upgrade = "true"
  allow_minor_version_upgrade = "true"
  db_instance_class           = "db.t4g.small"
  db_engine_version           = "18"
  db_engine                   = "postgres"
  rds_family                  = "postgres18"
  # db_password_rotated_date    = "07-01-2026"
  prepare_for_major_upgrade   = false

  enable_irsa = true

  db_parameter = [
    {
      name         = "rds.logical_replication"
      value        = "1"
      apply_method = "pending-reboot"
    },
    {
      name         = "shared_preload_libraries"
      value        = "pglogical"
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
}


resource "kubernetes_secret" "accommodation_data_domain_rds" {
  metadata {
    name      = "accommodation-data-domain-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.accommodation_data_domain_rds.rds_instance_endpoint
    database_name         = module.accommodation_data_domain_rds.database_name
    database_username     = module.accommodation_data_domain_rds.database_username
    database_password     = module.accommodation_data_domain_rds.database_password
    rds_instance_address  = module.accommodation_data_domain_rds.rds_instance_address
  }
}