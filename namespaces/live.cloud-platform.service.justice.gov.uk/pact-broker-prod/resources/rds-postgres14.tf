module "pact_broker_rds_postgres14" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.19.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  rds_family                  = "postgres14"
  db_engine_version           = "14"
  db_instance_class           = "db.t3.small"
  allow_major_version_upgrade = "false"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "pact_broker_rds_postgres14_secrets" {
  metadata {
    name      = "postgres14"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.pact_broker_rds_postgres14.rds_instance_endpoint
    database_name         = module.pact_broker_rds_postgres14.database_name
    database_username     = module.pact_broker_rds_postgres14.database_username
    database_password     = module.pact_broker_rds_postgres14.database_password
    rds_instance_address  = module.pact_broker_rds_postgres14.rds_instance_address
    access_key_id         = module.pact_broker_rds_postgres14.access_key_id
    secret_access_key     = module.pact_broker_rds_postgres14.secret_access_key
    url                   = "postgres://${module.pact_broker_rds_postgres14.database_username}:${module.pact_broker_rds_postgres14.database_password}@${module.pact_broker_rds_postgres14.rds_instance_endpoint}/${module.pact_broker_rds_postgres14.database_name}"
  }
}
