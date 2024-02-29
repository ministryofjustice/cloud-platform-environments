module "hmcts-complaints-adapter-rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"

  vpc_name                   = var.vpc_name
  db_backup_retention_period = var.db_backup_retention_period_hmcts_complaints_adapter
  application                = "hmcts-complaints-formbuilder-adapter"
  environment_name           = var.environment-name
  is_production              = var.is_production
  namespace                  = var.namespace
  infrastructure_support     = var.infrastructure_support
  team_name                  = var.team_name
  business_unit              = "Platforms"

  db_engine_version        = "14.10"
  rds_family               = "postgres14"
  db_instance_class        = "db.t4g.micro"
  db_max_allocated_storage = "500" # maximum storage for autoscaling

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmcts-complaints-adapter-rds-instance" {
  metadata {
    name      = "rds-instance-hmcts-complaints-adapter-${var.environment-name}"
    namespace = "hmcts-complaints-formbuilder-adapter-${var.environment-name}"
  }

  data = {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.hmcts-complaints-adapter-rds-instance.database_username}:${module.hmcts-complaints-adapter-rds-instance.database_password}@${module.hmcts-complaints-adapter-rds-instance.rds_instance_endpoint}/${module.hmcts-complaints-adapter-rds-instance.database_name}"
  }
}
