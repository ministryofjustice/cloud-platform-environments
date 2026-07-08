module "grafana_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  db_engine                = "postgres"
  db_engine_version        = "17"
  rds_family               = "postgres17"
  db_instance_class        = "db.t4g.micro"
  db_max_allocated_storage = "50"
  vpc_name                 = var.vpc_name

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "grafana_rds" {
  metadata {
    namespace = var.namespace
    name      = "grafana-rds"
  }

  data = {
    rds_instance_endpoint = module.grafana_rds.rds_instance_endpoint
    database_name         = module.grafana_rds.database_name
    database_username     = module.grafana_rds.database_username
    database_password     = module.grafana_rds.database_password
    rds_instance_address  = module.grafana_rds.rds_instance_address
  }
}
