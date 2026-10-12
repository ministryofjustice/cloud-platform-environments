module "hmpps_legal_status_api_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # PostgreSQL specifics
  prepare_for_major_upgrade   = false
  allow_minor_version_upgrade = true
  db_engine                   = "postgres"
  db_engine_version           = "18.6"
  rds_family                  = "postgres18"
  db_instance_class           = "db.t4g.micro"
  db_allocated_storage        = 20
  db_max_allocated_storage    = "100"
  storage_type                = "gp3"

  enable_rds_auto_start_stop = true

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps_legal_status_api_rds.rds_instance_endpoint
    database_name         = module.hmpps_legal_status_api_rds.database_name
    db_identifier         = module.hmpps_legal_status_api_rds.db_identifier
    database_username     = module.hmpps_legal_status_api_rds.database_username
    database_password     = module.hmpps_legal_status_api_rds.database_password
    rds_instance_address  = module.hmpps_legal_status_api_rds.rds_instance_address
  }
}
