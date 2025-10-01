module "hmpps_person_match_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support
  db_max_allocated_storage    = "500"
  rds_family                  = "postgres16"
  db_instance_class           = "db.r6g.xlarge"
  db_engine                   = "postgres"
  db_engine_version           = "16"
  prepare_for_major_upgrade   = false
  allow_major_version_upgrade = "true"
  enable_rds_auto_start_stop  = false
  deletion_protection         = true

  providers = {
    aws = aws.london
  }

  enable_irsa = true
}

resource "kubernetes_secret" "hmpps_person_match_rds" {
  metadata {
    name      = "hmpps-person-match-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps_person_match_rds.rds_instance_endpoint
    database_name         = module.hmpps_person_match_rds.database_name
    database_username     = module.hmpps_person_match_rds.database_username
    database_password     = module.hmpps_person_match_rds.database_password
    rds_instance_address  = module.hmpps_person_match_rds.rds_instance_address
    url                   = "postgres://${module.hmpps_person_match_rds.database_username}:${module.hmpps_person_match_rds.database_password}@${module.hmpps_person_match_rds.rds_instance_endpoint}/${module.hmpps_person_match_rds.database_name}"
  }
}
