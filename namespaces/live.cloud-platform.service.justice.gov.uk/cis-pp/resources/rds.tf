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
  db_name                  = "cis-rds"
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