module "hmpps_person_record_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  rds_family             = "postgres16"
  db_instance_class      = "db.t3.xlarge"
  db_engine              = "postgres"
  db_engine_version      = "16.1"
  prepare_for_major_upgrade = true
  allow_major_version_upgrade = "true"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_person_record_rds" {
  metadata {
    name      = "hmpps-person-record-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps_person_record_rds.rds_instance_endpoint
    database_name         = module.hmpps_person_record_rds.database_name
    database_username     = module.hmpps_person_record_rds.database_username
    database_password     = module.hmpps_person_record_rds.database_password
    rds_instance_address  = module.hmpps_person_record_rds.rds_instance_address
    url                   = "postgres://${module.hmpps_person_record_rds.database_username}:${module.hmpps_person_record_rds.database_password}@${module.hmpps_person_record_rds.rds_instance_endpoint}/${module.hmpps_person_record_rds.database_name}"
  }
}
