module "hmpps_service_catalogue" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = "hmpps-service-catalogue"
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support
  allow_major_version_upgrade = "false"
  db_instance_class           = "db.t4g.micro"
  db_max_allocated_storage    = "500" # maximum storage for autoscaling
  db_engine_version           = "15"
  rds_family                  = "postgres15"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_service_catalogue" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps_service_catalogue.rds_instance_endpoint
    database_name         = module.hmpps_service_catalogue.database_name
    database_username     = module.hmpps_service_catalogue.database_username
    database_password     = module.hmpps_service_catalogue.database_password
    rds_instance_address  = module.hmpps_service_catalogue.rds_instance_address
  }
}
