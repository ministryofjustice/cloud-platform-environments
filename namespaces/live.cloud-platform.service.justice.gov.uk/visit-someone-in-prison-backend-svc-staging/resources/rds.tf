module "visit_scheduler_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  db_engine_version           = "13"
  db_instance_class           = "db.t4g.micro"
  db_max_allocated_storage    = "500"
  rds_family                  = "postgres13"
  allow_major_version_upgrade = "false"
  db_password_rotated_date    = "2023-03-22"

  enable_rds_auto_start_stop   = true
  performance_insights_enabled = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "visit_scheduler_rds" {
  metadata {
    name      = "visit-scheduler-rds"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.visit_scheduler_rds.rds_instance_endpoint
    database_name         = module.visit_scheduler_rds.database_name
    database_username     = module.visit_scheduler_rds.database_username
    database_password     = module.visit_scheduler_rds.database_password
    rds_instance_address  = module.visit_scheduler_rds.rds_instance_address
  }
}
