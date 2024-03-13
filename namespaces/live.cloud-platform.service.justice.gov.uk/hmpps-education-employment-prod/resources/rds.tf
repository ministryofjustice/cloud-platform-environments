module "edu_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support
  rds_family                  = "postgres15"
  prepare_for_major_upgrade   = true
  allow_major_version_upgrade = true
  db_instance_class           = "db.t4g.small"
  db_max_allocated_storage    = "10000"
  db_engine_version           = "15.6"
  deletion_protection         = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "edu_rds" {
  metadata {
    name      = "edu-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.edu_rds.rds_instance_endpoint
    database_name         = module.edu_rds.database_name
    database_username     = module.edu_rds.database_username
    database_password     = module.edu_rds.database_password
    rds_instance_address  = module.edu_rds.rds_instance_address
    url                   = "postgres://${module.edu_rds.database_username}:${module.edu_rds.database_password}@${module.edu_rds.rds_instance_endpoint}/${module.edu_rds.database_name}"
  }
}
