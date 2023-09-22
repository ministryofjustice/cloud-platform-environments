/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

module "lcdui_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.0"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment-name
  infrastructure_support      = var.infrastructure_support
  db_allocated_storage        = "10"
  db_instance_class           = "db.t4g.small"
  prepare_for_major_upgrade   = false
  db_engine                   = "postgres"
  db_engine_version           = "14.7"
  rds_family                  = "postgres14"
  allow_major_version_upgrade = "true"


  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "lcdui_rds" {
  metadata {
    name      = "lcdui-rds"
    namespace = var.namespace
  }

  data = {
    # postgres://username:password@instance_endpoint/database_name
    url = "postgres://${module.lcdui_rds.database_username}:${module.lcdui_rds.database_password}@${module.lcdui_rds.rds_instance_endpoint}/${module.lcdui_rds.database_name}"
  }
}
