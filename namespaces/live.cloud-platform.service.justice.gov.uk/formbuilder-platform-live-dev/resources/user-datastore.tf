module "user-datastore-rds-instance-2" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"

  vpc_name                   = var.vpc_name
  db_backup_retention_period = var.db_backup_retention_period_user_datastore
  application                = "formbuilderuserdatastore"
  environment_name           = var.environment-name
  is_production              = var.is_production
  namespace                  = var.namespace
  infrastructure_support     = var.infrastructure_support
  team_name                  = var.team_name
  business_unit              = "transformed-department"
  prepare_for_major_upgrade  = true
  db_engine_version          = "15.5"
  rds_family                 = "postgres15"
  db_instance_class          = var.db_instance_class

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
