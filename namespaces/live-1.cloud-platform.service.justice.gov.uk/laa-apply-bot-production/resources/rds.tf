/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.12"

  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  team_name              = "apply-for-legal-aid"
  business-unit          = "laa"
  application            = "laa-apply-bot"
  is-production          = "true"
  namespace              = var.namespace
  environment-name       = "production"
  infrastructure-support = "apply@digital.justice.gov.uk"
  db_engine              = "postgres"
  db_engine_version      = "11"
  db_name                = "laa_apply_bot_production"
  rds_family             = "postgres11"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    rds_instance_address  = module.rds.rds_instance_address
    access_key_id         = module.rds.access_key_id
    secret_access_key     = module.rds.secret_access_key
    url                   = "postgres://${module.rds.database_username}:${module.rds.database_password}@${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
  }
}

