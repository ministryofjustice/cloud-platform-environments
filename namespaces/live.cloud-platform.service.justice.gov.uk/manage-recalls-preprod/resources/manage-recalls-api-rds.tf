##
## PostgreSQL - Application Database
##

module "manage_recalls_api_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.10"

  cluster_name           = var.cluster_name
  namespace              = var.namespace
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  team_name              = var.team_name

  rds_name          = "manage-recalls-${var.environment}"
  rds_family        = "postgres13"
  db_engine         = "postgres"
  db_engine_version = "13"
  db_instance_class = "db.t3.small"
  db_name           = "manage_recalls"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "manage_recalls_api_rds" {
  metadata {
    name      = "manage-recalls-api-database"
    namespace = var.namespace
  }

  data = {
    host     = module.manage_recalls_api_rds.rds_instance_address
    name     = module.manage_recalls_api_rds.database_name
    username = module.manage_recalls_api_rds.database_username
    password = module.manage_recalls_api_rds.database_password
  }
}
