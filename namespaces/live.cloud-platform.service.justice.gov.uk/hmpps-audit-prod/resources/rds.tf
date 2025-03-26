module "hmpps_audit_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.0.1"
  db_allocated_storage   = 10
  storage_type           = "gp2"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  db_instance_class            = "db.t4g.small"
  db_engine                    = "postgres"
  db_engine_version            = "16"
  rds_family                   = "postgres16"
  db_max_allocated_storage     = "10000"
  prepare_for_major_upgrade    = false
  deletion_protection          = true
  performance_insights_enabled = true

  providers = {
    aws = aws.london
  }

}

resource "kubernetes_secret" "hmpps_audit_rds" {
  metadata {
    name      = "hmpps-audit-rds-secret"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps_audit_rds.rds_instance_endpoint
    database_name         = module.hmpps_audit_rds.database_name
    database_username     = module.hmpps_audit_rds.database_username
    database_password     = module.hmpps_audit_rds.database_password
    rds_instance_address  = module.hmpps_audit_rds.rds_instance_address
  }
}
