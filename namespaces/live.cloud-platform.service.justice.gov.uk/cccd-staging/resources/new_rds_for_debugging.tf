# This new database should not be connected with any apps.
# This is just for debugging, so that we can pg_dump an older snapshot of the database

module "cccd_temp_fake_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.0"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment-name
  infrastructure_support      = var.infrastructure_support
  db_allocated_storage        = "50"
  db_instance_class           = "db.t3.medium"
  db_engine_version           = "13"
  rds_family                  = "postgres13"
  allow_major_version_upgrade = "true"
  db_parameter                = [{ name = "rds.force_ssl", value = "0", apply_method = "immediate" }]

  snapshot_identifier = "cloud-platform-7c41317651c21a33-finalsnapshot"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "cccd_temp_fake_rds" {
  metadata {
    name      = "cccd_temp_fake_rds"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.cccd_temp_fake_rds.rds_instance_endpoint
    database_name         = module.cccd_temp_fake_rds.database_name
    database_username     = module.cccd_temp_fake_rds.database_username
    database_password     = module.cccd_temp_fake_rds.database_password
    rds_instance_address  = module.cccd_temp_fake_rds.rds_instance_address
    url                   = "postgres://${module.cccd_temp_fake_rds.database_username}:${module.cccd_temp_fake_rds.database_password}@${module.cccd_temp_fake_rds.rds_instance_endpoint}/${module.cccd_temp_fake_rds.database_name}"
  }
}