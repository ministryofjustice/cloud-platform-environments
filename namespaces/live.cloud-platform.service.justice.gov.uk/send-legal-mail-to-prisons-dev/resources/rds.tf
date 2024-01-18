module "slmtp_api_rds" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name                   = var.vpc_name
  team_name                  = var.team_name
  business_unit              = var.business_unit
  application                = var.application
  is_production              = var.is_production
  namespace                  = var.namespace
  environment_name           = var.environment
  infrastructure_support     = var.infrastructure_support
  enable_rds_auto_start_stop = true

  allow_major_version_upgrade = "false"
  prepare_for_major_upgrade   = false
  db_instance_class           = "db.t4g.micro"
  db_max_allocated_storage    = "500"
  db_engine                   = "postgres"
  rds_family                  = "postgres15"
  db_engine_version           = "15.5"
  db_password_rotated_date    = "2023-03-22"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "slmtp_api_rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.slmtp_api_rds.rds_instance_endpoint
    database_name         = module.slmtp_api_rds.database_name
    database_username     = module.slmtp_api_rds.database_username
    database_password     = module.slmtp_api_rds.database_password
    rds_instance_address  = module.slmtp_api_rds.rds_instance_address
  }
}
