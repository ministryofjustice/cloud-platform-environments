module "dps_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.12"
  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.court-application
  is-production          = var.is-production
  namespace              = var.namespace
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support

  rds_family        = "postgres11"
  db_engine_version = "11"

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
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.12"
  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.prison-application
  is-production          = var.is-production
  namespace              = var.namespace
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support

  rds_family        = "postgres11"
  db_engine_version = "11"

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
