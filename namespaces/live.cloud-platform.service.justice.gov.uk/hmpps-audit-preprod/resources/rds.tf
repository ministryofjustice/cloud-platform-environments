module "hmpps_audit_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.18.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure_support

  db_instance_class           = "db.t4g.micro"
  db_max_allocated_storage    = "500"
  rds_family                  = "postgres15"
  db_engine_version           = "15"
  deletion_protection         = true
  db_engine = "postgres"
  prepare_for_major_upgrade   = false

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
