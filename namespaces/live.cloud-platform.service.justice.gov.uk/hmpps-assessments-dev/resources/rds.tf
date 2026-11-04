
module "hmpps_assessments_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  db_allocated_storage   = 20
  storage_type           = "gp3"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  rds_family             = "postgres18"
  db_instance_class      = "db.t4g.small"
  db_engine              = "postgres"
  db_engine_version      = "18.6"

  allow_major_version_upgrade = "true"
  prepare_for_major_upgrade   = false

  providers = {
    aws = aws.london
  }


  enable_irsa = true
}

resource "kubernetes_secret" "hmpps_assessments_rds" {
  metadata {
    name      = "hmpps-assessments-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps_assessments_rds.rds_instance_endpoint
    database_name         = module.hmpps_assessments_rds.database_name
    database_username     = module.hmpps_assessments_rds.database_username
    database_password     = module.hmpps_assessments_rds.database_password
    rds_instance_address  = module.hmpps_assessments_rds.rds_instance_address
    url                   = "postgres://${module.hmpps_assessments_rds.database_username}:${module.hmpps_assessments_rds.database_password}@${module.hmpps_assessments_rds.rds_instance_endpoint}/${module.hmpps_assessments_rds.database_name}"
  }
}
