module "checkmydiary_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.0"

  vpc_name                   = var.vpc_name
  team_name                  = var.team_name
  business_unit              = "HMPPS"
  application                = var.application
  is_production              = var.is_production
  namespace                  = var.namespace
  environment_name           = var.environment
  infrastructure_support     = var.infrastructure_support
  db_max_allocated_storage   = "500"
  db_instance_class          = "db.t4g.micro"
  db_engine                  = "postgres"
  db_engine_version          = "16"
  rds_family                 = "postgres16"
  db_password_rotated_date   = "2023-02-21"
  deletion_protection        = true
  prepare_for_major_upgrade  = true
  enable_rds_auto_start_stop = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "checkmydiary_rds_secrets" {
  metadata {
    name      = "check-my-diary-rds"
    namespace = "check-my-diary-preprod"
  }

  data = {
    rds_instance_endpoint = module.checkmydiary_rds.rds_instance_endpoint
    database_name         = module.checkmydiary_rds.database_name
    database_username     = module.checkmydiary_rds.database_username
    database_password     = module.checkmydiary_rds.database_password
    rds_instance_address  = module.checkmydiary_rds.rds_instance_address
  }
}
