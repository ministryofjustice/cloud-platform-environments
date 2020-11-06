module "submitter-rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.10"

  cluster_name               = var.cluster_name
  cluster_state_bucket       = var.cluster_state_bucket
  db_backup_retention_period = var.db_backup_retention_period_submitter
  application                = "formbuildersubmitter"
  environment-name           = var.environment-name
  is-production              = var.is-production
  namespace                  = var.namespace
  infrastructure-support     = var.infrastructure-support
  team_name                  = var.team_name
  deletion_protection        = var.deletion_protection
  backup_window              = "03:00-06:00"

  db_engine_version = "10"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "submitter-rds-instance" {
  metadata {
    name      = "rds-instance-formbuilder-submitter-${var.environment-name}"
    namespace = "formbuilder-platform-${var.environment-name}"
  }

  data = {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.submitter-rds-instance.database_username}:${module.submitter-rds-instance.database_password}@${module.submitter-rds-instance.rds_instance_endpoint}/${module.submitter-rds-instance.database_name}"
  }
}

