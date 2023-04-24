module "dps_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.18.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.court-application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure_support

  db_instance_class          = "db.t4g.small"
  db_max_allocated_storage   = "10000"
  deletion_protection        = true
  prepare_for_major_upgrade  = false
  rds_family                 = "postgres15"
  db_engine                  = "postgres"
  db_engine_version          = "15"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "dps_rds" {
  metadata {
    name      = "dps-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.dps_rds.rds_instance_endpoint
    database_name         = module.dps_rds.database_name
    database_username     = module.dps_rds.database_username
    database_password     = module.dps_rds.database_password
    rds_instance_address  = module.dps_rds.rds_instance_address
    access_key_id         = module.dps_rds.access_key_id
    secret_access_key     = module.dps_rds.secret_access_key
  }
}

module "prisons_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.18.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.prison-application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure_support

  allow_major_version_upgrade = "false"
  db_instance_class           = "db.t3.small"
  rds_family                  = "postgres14"
  db_engine_version           = "14"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prisons_rds" {
  metadata {
    name      = "prisons-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.prisons_rds.rds_instance_endpoint
    database_name         = module.prisons_rds.database_name
    database_username     = module.prisons_rds.database_username
    database_password     = module.prisons_rds.database_password
    rds_instance_address  = module.prisons_rds.rds_instance_address
    access_key_id         = module.prisons_rds.access_key_id
    secret_access_key     = module.prisons_rds.secret_access_key
  }
}
