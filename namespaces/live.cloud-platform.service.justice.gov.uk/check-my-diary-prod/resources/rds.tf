module "checkmydiary_rds" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  db_allocated_storage = 10
  storage_type         = "gp2"

  vpc_name                  = var.vpc_name
  team_name                 = var.team_name
  business_unit             = "HMPPS"
  application               = var.application
  is_production             = var.is_production
  namespace                 = var.namespace
  environment_name          = var.environment
  infrastructure_support    = var.infrastructure_support
  db_instance_class         = "db.t4g.small"
  db_engine                 = "postgres"
  db_engine_version         = "18"
  rds_family                = "postgres18"
  db_password_rotated_date  = "2023-02-21"
  deletion_protection       = true
  prepare_for_major_upgrade = true

  providers = {
    aws = aws.london
  }

}

resource "kubernetes_secret" "checkmydiary_rds_secrets" {
  metadata {
    name      = "check-my-diary-rds"
    namespace = "check-my-diary-prod"
  }

  data = {
    rds_instance_endpoint = module.checkmydiary_rds.rds_instance_endpoint
    database_name         = module.checkmydiary_rds.database_name
    database_username     = module.checkmydiary_rds.database_username
    database_password     = module.checkmydiary_rds.database_password
    rds_instance_address  = module.checkmydiary_rds.rds_instance_address
  }
}
