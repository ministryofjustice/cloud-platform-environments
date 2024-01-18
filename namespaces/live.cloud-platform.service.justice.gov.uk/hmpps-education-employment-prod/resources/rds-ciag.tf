module "ciag_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = "ciag-careers-induction-api"
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support
  rds_family                  = "postgres15"
  allow_major_version_upgrade = "false"
  db_instance_class           = "db.t4g.small"
  db_max_allocated_storage    = "10000"
  db_engine_version           = "15"
  deletion_protection         = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ciag_rds" {
  metadata {
    name      = "ciag-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.ciag_rds.rds_instance_endpoint
    database_name         = module.ciag_rds.database_name
    database_username     = module.ciag_rds.database_username
    database_password     = module.ciag_rds.database_password
    rds_instance_address  = module.ciag_rds.rds_instance_address
    url                   = "postgres://${module.ciag_rds.database_username}:${module.ciag_rds.database_password}@${module.ciag_rds.rds_instance_endpoint}/${module.ciag_rds.database_name}"
  }
}
