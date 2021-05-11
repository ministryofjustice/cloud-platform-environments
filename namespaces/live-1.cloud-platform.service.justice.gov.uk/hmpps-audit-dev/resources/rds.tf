module "hmpps_audit_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16"
  cluster_name           = var.cluster_name
  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  namespace              = var.namespace
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support

  db_instance_class = "db.t3.small"
  rds_family        = "postgres13"
  db_engine_version = "13"

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
    access_key_id         = module.hmpps_audit_rds.access_key_id
    secret_access_key     = module.hmpps_audit_rds.secret_access_key
  }
}
