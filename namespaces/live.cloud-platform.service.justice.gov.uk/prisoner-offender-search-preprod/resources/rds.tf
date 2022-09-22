module "pos_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=rds-update-vpc-name"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  namespace              = var.namespace
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support

  allow_major_version_upgrade = "true"
  db_instance_class           = "db.t3.small"
  rds_family                  = "postgres14"
  db_engine_version           = "14"

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