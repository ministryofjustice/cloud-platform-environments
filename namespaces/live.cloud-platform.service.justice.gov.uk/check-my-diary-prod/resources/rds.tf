module "checkmydiary_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.18.0"

  vpc_name                 = var.vpc_name
  team_name                = var.team_name
  business-unit            = "HMPPS"
  application              = var.application
  is-production            = var.is_production
  namespace                = var.namespace
  environment-name         = var.environment
  infrastructure-support   = var.infrastructure_support
  db_instance_class        = "db.t4g.small"
  db_engine                = "postgres"
  db_engine_version        = "14"
  rds_family               = "postgres14"
  db_password_rotated_date = "2023-02-21"
  deletion_protection      = true

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "false"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "checkmydiary_rds_secrets" {
  metadata {
    name      = "check-my-diary-rds"
    namespace = "check-my-diary-prod"
  }

  data = {
    rds_instance_endpoint = module.checkmydiary_rds.rds_instance_endpoint
    database_name         = module.checkmydiary_rds.database_name
    database_username     = module.checkmydiary_rds.database_username
    database_password     = module.checkmydiary_rds.database_password
    rds_instance_address  = module.checkmydiary_rds.rds_instance_address
    access_key_id         = module.checkmydiary_rds.access_key_id
    secret_access_key     = module.checkmydiary_rds.secret_access_key
  }
}
