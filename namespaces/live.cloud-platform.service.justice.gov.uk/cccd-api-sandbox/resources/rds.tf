/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

module "cccd_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.1.0"
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

  snapshot_identifier = "rds:cloud-platform-b7a1b41afe63d036-2023-10-31-22-59"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "cccd_rds" {
  metadata {
    name      = "cccd-rds"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.cccd_rds.rds_instance_endpoint
    database_name         = module.cccd_rds.database_name
    database_username     = module.cccd_rds.database_username
    database_password     = module.cccd_rds.database_password
    rds_instance_address  = module.cccd_rds.rds_instance_address
    url                   = "postgres://${module.cccd_rds.database_username}:${module.cccd_rds.database_password}@${module.cccd_rds.rds_instance_endpoint}/${module.cccd_rds.database_name}"
  }
}
