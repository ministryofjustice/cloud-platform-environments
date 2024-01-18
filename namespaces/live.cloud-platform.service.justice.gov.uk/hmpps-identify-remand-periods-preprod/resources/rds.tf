module "identify_remand_periods_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment_name
  infrastructure_support      = var.infrastructure_support
  rds_family                  = var.rds_family
  allow_major_version_upgrade = "false"
  db_instance_class           = "db.t4g.micro"
  db_max_allocated_storage    = "500" # maximum storage for autoscaling
  db_engine_version           = "15"
  enable_rds_auto_start_stop  = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "identify_remand_periods_rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.identify_remand_periods_rds.rds_instance_endpoint
    database_name         = module.identify_remand_periods_rds.database_name
    database_username     = module.identify_remand_periods_rds.database_username
    database_password     = module.identify_remand_periods_rds.database_password
    rds_instance_address  = module.identify_remand_periods_rds.rds_instance_address
  }
}
