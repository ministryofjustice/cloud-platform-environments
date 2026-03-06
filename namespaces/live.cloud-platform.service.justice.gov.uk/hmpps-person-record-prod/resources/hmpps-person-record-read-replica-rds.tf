module "hmpps_person_record_rds_read_replica" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support
  rds_family                  = "postgres17"
  db_instance_class           = "db.t4g.small"
  db_engine                   = "postgres"
  db_engine_version           = "17.4"
  prepare_for_major_upgrade   = false
  allow_major_version_upgrade = "true"
  allow_minor_version_upgrade = "false"
  enable_rds_auto_start_stop  = true
  replicate_source_db         = module.hmpps_person_record_rds.db_identifier

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_person_record_rds_read_replica" {
  metadata {
    name      = "hmpps-person-record-rds-read-replica-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps_person_record_rds_read_replica.rds_instance_endpoint
    rds_instance_address  = module.hmpps_person_record_rds_read_replica.rds_instance_address
  }
}
