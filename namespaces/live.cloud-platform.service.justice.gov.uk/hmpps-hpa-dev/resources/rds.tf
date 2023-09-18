module "hmpps_hpa_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.19.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  db_engine              = "sqlserver-ex"
  db_engine_version      = "15.00"
  db_instance_class      = "db.t3.small"
  db_allocated_storage   = 20
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure_support
  rds_family             = "sqlserver-ex-15.0"
  db_parameter           = []
  license_model          = "license-included"

  performance_insights_enabled = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_hpa_rds" {
  metadata {
    name      = "rds-sqlserver-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps_hpa_rds.rds_instance_endpoint
    database_username     = module.hmpps_hpa_rds.database_username
    database_password     = module.hmpps_hpa_rds.database_password
    rds_instance_address  = module.hmpps_hpa_rds.rds_instance_address
    access_key_id         = module.hmpps_hpa_rds.access_key_id
    secret_access_key     = module.hmpps_hpa_rds.secret_access_key
  }
}
