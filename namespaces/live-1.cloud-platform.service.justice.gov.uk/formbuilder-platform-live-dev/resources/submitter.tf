module "submitter-rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.3"

  cluster_name               = var.cluster_name
  cluster_state_bucket       = var.cluster_state_bucket
  db_backup_retention_period = var.db_backup_retention_period_submitter
  application                = "formbuildersubmitter"
  environment-name           = var.environment-name
  is-production              = var.is-production
  infrastructure-support     = var.infrastructure-support
  team_name                  = var.team_name
  force_ssl                  = true
  db_engine_version          = "10.9"
  apply_method               = "immediate"

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

