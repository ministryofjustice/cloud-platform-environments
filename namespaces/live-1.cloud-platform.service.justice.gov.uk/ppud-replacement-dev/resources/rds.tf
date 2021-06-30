module "ppud_replacement_dev_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.3"

  cluster_name           = var.cluster_name
  namespace              = var.namespace
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  team_name              = var.team_name

  rds_name          = "ppud-replacement-dev"
  rds_family        = "postgres13"
  db_engine         = "postgres"
  db_engine_version = "13"
  db_instance_class = "db.t3.small"
  db_name           = "manage_recalls"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ppud_replacement_dev_rds_secrets" {
  metadata {
    name      = "manage-recalls-database"
    namespace = var.namespace
  }

  data = {
    host     = module.ppud_replacement_dev_rds.rds_instance_address
    name     = module.ppud_replacement_dev_rds.database_name
    username = module.ppud_replacement_dev_rds.database_username
    password = module.ppud_replacement_dev_rds.database_password
  }
}
