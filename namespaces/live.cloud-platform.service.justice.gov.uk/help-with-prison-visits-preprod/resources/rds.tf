module "hwpv_sqlserver" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.19.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  db_engine              = "sqlserver-web"
  db_engine_version      = "15.00"
  db_instance_class      = "db.t3.small"
  db_allocated_storage   = "20"
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure_support
  rds_family             = "sqlserver-web-15.0"
  db_parameter           = []
  license_model          = "license-included"
  db_password_rotated_date    = "2023-03-22"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hwpv_sqlserver" {
  metadata {
    name      = "rds-sqlserver-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hwpv_sqlserver.rds_instance_endpoint
    database_username     = module.hwpv_sqlserver.database_username
    database_password     = module.hwpv_sqlserver.database_password
    rds_instance_address  = module.hwpv_sqlserver.rds_instance_address
    access_key_id         = module.hwpv_sqlserver.access_key_id
    secret_access_key     = module.hwpv_sqlserver.secret_access_key
  }
}
