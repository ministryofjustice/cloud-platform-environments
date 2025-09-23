/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "allocation-rds" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.0.0"
  db_allocated_storage = 10
  storage_type         = "gp2"

  vpc_name                    = var.vpc_name
  db_instance_class           = "db.t4g.small"
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment_name
  infrastructure_support      = var.infrastructure_support
  db_engine                   = "postgres"
  db_engine_version           = "15.12"
  rds_family                  = "postgres15"
  allow_minor_version_upgrade = true
  allow_major_version_upgrade = false
  prepare_for_major_upgrade   = false
  db_name                     = "allocations"
  enable_rds_auto_start_stop  = true # 22:00–06:00 UTC
  maintenance_window          = "sun:19:00-sun:21:00"

  db_password_rotated_date = "2023-04-05T11:31:27Z"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "allocation-rds" {
  metadata {
    name      = "allocation-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.allocation-rds.rds_instance_endpoint
    rds_instance_address  = module.allocation-rds.rds_instance_address
    database_name         = module.allocation-rds.database_name
    database_username     = module.allocation-rds.database_username
    database_password     = module.allocation-rds.database_password
    postgres_name         = module.allocation-rds.database_name
    postgres_host         = module.allocation-rds.rds_instance_address
    postgres_user         = module.allocation-rds.database_username
    postgres_password     = module.allocation-rds.database_password
  }
}
