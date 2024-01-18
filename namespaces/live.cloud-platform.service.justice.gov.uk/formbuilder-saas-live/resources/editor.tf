module "editor-rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"

  vpc_name                   = var.vpc_name
  db_backup_retention_period = var.db_backup_retention_period
  application                = "formbuilder-editor"
  environment_name           = var.environment_name
  is_production              = var.is_production
  namespace                  = var.namespace
  infrastructure_support     = var.infrastructure_support
  team_name                  = var.team_name
  business_unit              = "Platforms"
  db_engine_version          = "12"
  rds_family                 = "postgres12"
  db_instance_class          = var.db_instance_class

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "editor-rds-instance" {
  metadata {
    name      = "rds-instance-formbuilder-editor-${var.environment_name}"
    namespace = "formbuilder-saas-${var.environment_name}"
  }

  data = {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.editor-rds-instance.database_username}:${module.editor-rds-instance.database_password}@${module.editor-rds-instance.rds_instance_endpoint}/${module.editor-rds-instance.database_name}"
  }
}
