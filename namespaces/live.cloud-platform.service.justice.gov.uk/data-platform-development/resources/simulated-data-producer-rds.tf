module "simulated_data_producer_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.19.0"

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
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
    access_key_id         = module.simulated_data_producer_rds.access_key_id
    secret_access_key     = module.simulated_data_producer_rds.secret_access_key
  }
}
