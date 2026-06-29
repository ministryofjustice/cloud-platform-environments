module "rds_instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # Database configuration
  db_engine                = "oracle-se2"
  db_engine_version        = "19.0.0.0.ru-2026-01.rur-2026-01.r3"
  rds_family               = "oracle-se2-19"
  db_instance_class        = "db.t3.small"
  db_allocated_storage     = "100"
  rds_name                 = "cis-rds"
  db_name                  = "CIS"
  license_model            = "license-included"
  
  # Avoid default parameters set by MOJ
  db_parameter = []

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "cis-rds-details"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_instance.rds_instance_endpoint
    database_name         = module.rds_instance.database_name
    database_username     = module.rds_instance.database_username
    database_password     = module.rds_instance.database_password
    database_address      = module.rds_instance.rds_instance_address
    database_port         = module.rds_instance.rds_instance_port
  }
}