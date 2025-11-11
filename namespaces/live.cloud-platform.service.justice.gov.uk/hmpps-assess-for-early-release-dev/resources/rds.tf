module "assess-for-early-release_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  db_allocated_storage        = 10
  storage_type                = "gp2"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support
  allow_minor_version_upgrade = true
  allow_major_version_upgrade = false
  db_instance_class           = "db.t4g.small"
  db_engine_version           = "16.3"
  rds_family                  = "postgres16"
  prepare_for_major_upgrade   = true
  db_password_rotated_date    = "14-02-2023"
  enable_rds_auto_start_stop  = true

  providers = {
    aws = aws.london
  }

}

resource "kubernetes_secret" "assess-for-early-release_rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.assess-for-early-release_rds.rds_instance_endpoint
    database_name         = module.assess-for-early-release_rds.database_name
    database_username     = module.assess-for-early-release_rds.database_username
    database_password     = module.assess-for-early-release_rds.database_password
    rds_instance_address  = module.assess-for-early-release_rds.rds_instance_address
  }
}
