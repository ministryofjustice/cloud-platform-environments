module "editor-rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.12"

  cluster_name               = var.cluster_name
  cluster_state_bucket       = var.cluster_state_bucket
  db_backup_retention_period = var.db_backup_retention_period
  application                = "formbuilder-editor"
  environment-name           = var.environment_name
  is-production              = var.is_production
  namespace                  = var.namespace
  infrastructure-support     = var.infrastructure_support
  team_name                  = var.team_name
  db_engine_version          = "12"
  rds_family                 = "postgres12"

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
