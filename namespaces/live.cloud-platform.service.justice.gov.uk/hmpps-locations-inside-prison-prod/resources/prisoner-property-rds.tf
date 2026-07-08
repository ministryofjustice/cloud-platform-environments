# RDS Postgres instance for hmpps-prisoner-property-api.
# Lives in the shared hmpps-locations-inside-prison-<env> namespace alongside the existing
# dps_rds instance. Modelled on the namespace's existing resources/rds.tf.
# NOTE: data.aws_security_group.mp_dps_sg is already declared in the existing rds.tf in this
# folder, so it is reused here (do not redeclare).

module "prisoner_property_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  performance_insights_enabled = true

  db_instance_class           = "db.t4g.large"
  rds_name                    = "hmpps-prisoner-property-api-prod"
  rds_family                  = "postgres18"
  db_engine_version           = "18"
  deletion_protection         = true
  allow_major_version_upgrade = "false"
  allow_minor_version_upgrade = "true"

  providers = {
    aws = aws.london
  }

  vpc_security_group_ids = [data.aws_security_group.mp_dps_sg.id]
}

resource "kubernetes_secret" "prisoner_property_rds" {
  metadata {
    name      = "prisoner-property-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    db_identifier         = module.prisoner_property_rds.db_identifier
    resource_id           = module.prisoner_property_rds.resource_id
    rds_instance_endpoint = module.prisoner_property_rds.rds_instance_endpoint
    database_name         = module.prisoner_property_rds.database_name
    database_username     = module.prisoner_property_rds.database_username
    database_password     = module.prisoner_property_rds.database_password
    rds_instance_address  = module.prisoner_property_rds.rds_instance_address
    url                   = "postgres://${module.prisoner_property_rds.database_username}:${module.prisoner_property_rds.database_password}@${module.prisoner_property_rds.rds_instance_endpoint}/${module.prisoner_property_rds.database_name}"
  }
}
