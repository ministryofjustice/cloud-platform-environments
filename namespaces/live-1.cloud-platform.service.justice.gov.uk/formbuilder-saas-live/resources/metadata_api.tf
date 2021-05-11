module "metadata-api-rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16"

  cluster_name               = var.cluster_name
  db_backup_retention_period = var.db_backup_retention_period
  application                = "formbuilder-metadata-api"
  environment-name           = var.environment_name
  is-production              = var.is_production
  namespace                  = var.namespace
  infrastructure-support     = var.infrastructure_support
  team_name                  = var.team_name
  db_engine_version          = "12"
  rds_family                 = "postgres12"
  db_allocated_storage       = "300"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "metadata-api-rds-instance" {
  metadata {
    name      = "rds-instance-formbuilder-metadata-api-${var.environment_name}"
    namespace = "formbuilder-saas-${var.environment_name}"
  }

  data = {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.metadata-api-rds-instance.database_username}:${module.metadata-api-rds-instance.database_password}@${module.metadata-api-rds-instance.rds_instance_endpoint}/${module.metadata-api-rds-instance.database_name}"
  }
}
