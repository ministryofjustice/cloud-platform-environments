module "visit_scheduler_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.19.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  db_engine_version           = "13"
  db_instance_class           = "db.t4g.small"
  db_max_allocated_storage    = "10000"
  rds_family                  = "postgres13"
  allow_major_version_upgrade = "false"
  db_password_rotated_date    = "2023-05-11"

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
    access_key_id         = module.visit_scheduler_rds.access_key_id
    secret_access_key     = module.visit_scheduler_rds.secret_access_key
  }
}
