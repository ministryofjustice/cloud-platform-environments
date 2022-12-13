module "dps_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.14"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  namespace              = var.namespace
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  db_instance_class      = "db.t4g.small"
  db_engine              = "postgres"
  db_engine_version      = "14"
  rds_family             = "postgres14"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = false


  providers = {
    aws = aws.london
  }
}

resource "random_id" "offender_events_role_password" {
  byte_length = 32
}

resource "kubernetes_secret" "dps_rds" {
  metadata {
    name      = "dps-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint    = module.dps_rds.rds_instance_endpoint
    database_name            = module.dps_rds.database_name
    database_username        = module.dps_rds.database_username
    database_password        = module.dps_rds.database_password
    rds_instance_address     = module.dps_rds.rds_instance_address
    access_key_id            = module.dps_rds.access_key_id
    secret_access_key        = module.dps_rds.secret_access_key
    offender_events_password = random_id.offender_events_role_password.b64
  }
}

