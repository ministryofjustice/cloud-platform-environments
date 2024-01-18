module "simulated_data_producer_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  vpc_name                    = var.vpc_name
  rds_family                  = "postgres14"
  db_engine                   = "postgres"
  db_engine_version           = "14"
  db_instance_class           = "db.t4g.small"
  db_name                     = "simulated_data_producer"
  allow_minor_version_upgrade = true
  enable_rds_auto_start_stop  = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "simulated_data_producer_rds" {
  metadata {
    namespace = var.namespace
    name      = "cloud-platform-simulated-data-producer-rds"
  }

  data = {
    rds_instance_endpoint = module.simulated_data_producer_rds.rds_instance_endpoint
    database_name         = module.simulated_data_producer_rds.database_name
    database_username     = module.simulated_data_producer_rds.database_username
    database_password     = module.simulated_data_producer_rds.database_password
    rds_instance_address  = module.simulated_data_producer_rds.rds_instance_address
  }
}
