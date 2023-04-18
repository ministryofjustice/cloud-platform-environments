module "pos_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.18.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure_support

  allow_major_version_upgrade = "false"
  db_instance_class           = "db.t3.small"
  rds_family                  = "postgres14"
  db_engine_version           = "14"
  db_password_rotated_date    = "2023-02-21"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "pos_rds" {
  metadata {
    name      = "pos-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.pos_rds.rds_instance_endpoint
    database_name         = module.pos_rds.database_name
    database_username     = module.pos_rds.database_username
    database_password     = module.pos_rds.database_password
    rds_instance_address  = module.pos_rds.rds_instance_address
    access_key_id         = module.pos_rds.access_key_id
    secret_access_key     = module.pos_rds.secret_access_key
    url                   = "postgres://${module.pos_rds.database_username}:${module.pos_rds.database_password}@${module.pos_rds.rds_instance_endpoint}/${module.pos_rds.database_name}"
  }
}
