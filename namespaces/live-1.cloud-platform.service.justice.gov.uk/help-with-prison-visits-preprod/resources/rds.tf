module "hwpv_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16"
  cluster_name           = var.cluster_name
  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  db_engine_version      = "11"
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support

  rds_family = "postgres11"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hwpv_rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hwpv_rds.rds_instance_endpoint
    database_name         = module.hwpv_rds.database_name
    database_username     = module.hwpv_rds.database_username
    database_password     = module.hwpv_rds.database_password
    rds_instance_address  = module.hwpv_rds.rds_instance_address
    access_key_id         = module.hwpv_rds.access_key_id
    secret_access_key     = module.hwpv_rds.secret_access_key
    url                   = "postgres://${module.hwpv_rds.database_username}:${module.hwpv_rds.database_password}@${module.hwpv_rds.rds_instance_endpoint}/${module.hwpv_rds.database_name}"
  }
}

