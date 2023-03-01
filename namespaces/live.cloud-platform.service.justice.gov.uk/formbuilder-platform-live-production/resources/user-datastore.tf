module "user-datastore-rds-instance-2" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.17.0"

  vpc_name                   = var.vpc_name
  db_backup_retention_period = var.db_backup_retention_period_user_datastore
  application                = "formbuilderuserdatastore"
  environment-name           = var.environment-name
  is-production              = var.is-production
  namespace                  = var.namespace
  infrastructure-support     = var.infrastructure-support
  team_name                  = var.team_name
  db_engine_version          = "14"
  rds_family                 = "postgres14"
  db_instance_class          = var.db_instance_class
  db_allocated_storage       = "100"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "user-datastore-rds-instance-2" {
  metadata {
    name      = "rds-instance-formbuilder-user-datastore-2-${var.environment-name}"
    namespace = "formbuilder-platform-${var.environment-name}"
  }

  data = {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.user-datastore-rds-instance-2.database_username}:${module.user-datastore-rds-instance-2.database_password}@${module.user-datastore-rds-instance-2.rds_instance_endpoint}/${module.user-datastore-rds-instance-2.database_name}"
  }
}
