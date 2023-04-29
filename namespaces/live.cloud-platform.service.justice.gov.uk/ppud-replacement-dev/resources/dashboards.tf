##
## PostgreSQL - ppud-replacement-dashboards Database
##

module "ppud_replacement_dashboards_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.18.0"

  vpc_name               = var.vpc_name
  namespace              = var.namespace
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  team_name              = var.team_name

  rds_name          = "ppud-replacement-dashboards"
  rds_family        = "postgres13"
  db_engine         = "postgres"
  db_engine_version = "13"
  db_instance_class = "db.t3.small"
  db_name           = "dashboards"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ppud_replacement_dashboards_rds" {
  metadata {
    name      = "dashboards-database"
    namespace = var.namespace
  }

  data = {
    host         = module.ppud_replacement_dashboards_rds.rds_instance_address
    port         = module.ppud_replacement_dashboards_rds.rds_instance_port
    endpoint     = module.ppud_replacement_dashboards_rds.rds_instance_endpoint
    dbname       = module.ppud_replacement_dashboards_rds.database_name
    username     = module.ppud_replacement_dashboards_rds.database_username
    password     = module.ppud_replacement_dashboards_rds.database_password
    DATABASE_URL = "postgres://${module.ppud_replacement_dashboards_rds.database_username}:${module.ppud_replacement_dashboards_rds.database_password}@${module.ppud_replacement_dashboards_rds.rds_instance_endpoint}/${module.ppud_replacement_dashboards_rds.database_name}"
  }
}
