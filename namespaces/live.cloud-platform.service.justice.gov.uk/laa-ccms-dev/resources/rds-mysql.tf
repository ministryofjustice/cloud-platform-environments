module "opa_hub_db" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  enable_rds_auto_start_stop   = false

  # MySQL specifics
  db_engine         = "mysql"
  db_engine_version = "8.0.40"
  rds_family        = "mysql8.0"
  db_instance_class = "db.t4g.micro"
  db_parameter      = []

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "kubernetes_secret" "opa_hub_db" {
  metadata {
    name      = "opa-hub-db-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.opa_hub_db.rds_instance_endpoint
    database_name         = module.opa_hub_db.database_name
    database_username     = module.opa_hub_db.database_username
    database_password     = module.opa_hub_db.database_password
    rds_instance_address  = module.opa_hub_db.rds_instance_address
  }
}

resource "kubernetes_config_map" "opa_hub_db" {
  metadata {
    name      = "opa-hub-db-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.opa_hub_db.database_name
    db_identifier = module.opa_hub_db.db_identifier
  }
}
