module "court_case_service_rds_16" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  db_allocated_storage       = 10
  storage_type               = "gp2"
  vpc_name                   = var.vpc_name
  team_name                  = var.team_name
  business_unit              = var.business_unit
  namespace                  = var.namespace
  application                = var.application
  environment_name           = var.environment-name
  infrastructure_support     = var.infrastructure_support
  is_production              = var.is_production
  rds_family                 = var.rds_16_family
  db_engine                  = var.db_engine
  db_engine_version          = var.db_engine_version_16
  db_instance_class          = var.db_instance_class

  prepare_for_major_upgrade = true

  enable_rds_auto_start_stop = true
  db_password_rotated_date = "2025-10-14"


  providers = {
    aws = aws.london
  }

  enable_irsa = true

}

