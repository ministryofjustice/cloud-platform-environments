module "rds_instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # Database configuration
  db_engine                = "postgres"
  db_engine_version        = "18.6"
  rds_family               = "postgres18"
  db_instance_class        = "db.t4g.micro"
  db_max_allocated_storage = "500"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "rds_instance" {
  metadata {
    name      = "rds-instance-output" 
    namespace = var.namespace
  }

  data = {
    database_name         = module.rds_instance.database_name
    database_username     = module.rds_instance.database_username
    database_password     = module.rds_instance.database_password
    rds_instance_address  = module.rds_instance.rds_instance_address
    rds_instance_endpoint = module.rds_instance.rds_instance_endpoint
    rds_instance_port     = module.rds_instance.rds_instance_port
    url                   = "postgres://${module.rds_instance.database_username}:${module.rds_instance.database_password}@${module.rds_instance.rds_instance_endpoint}/${module.rds_instance.database_name}"
  }
}
