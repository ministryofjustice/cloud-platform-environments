module "submitter-rds-instance-2" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.18.0"

  vpc_name                   = var.vpc_name
  db_backup_retention_period = var.db_backup_retention_period_submitter
  application                = "formbuildersubmitter"
  environment-name           = var.environment-name
  is-production              = var.is_production
  namespace                  = var.namespace
  infrastructure-support     = var.infrastructure_support
  team_name                  = var.team_name
  db_engine_version          = "14"
  rds_family                 = "postgres14"
  db_instance_class          = var.db_instance_class

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "submitter-rds-instance-2" {
  metadata {
    name      = "rds-instance-formbuilder-submitter-2-${var.environment-name}"
    namespace = "formbuilder-platform-${var.environment-name}"
  }

  data = {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.submitter-rds-instance-2.database_username}:${module.submitter-rds-instance-2.database_password}@${module.submitter-rds-instance-2.rds_instance_endpoint}/${module.submitter-rds-instance-2.database_name}"
  }
}
