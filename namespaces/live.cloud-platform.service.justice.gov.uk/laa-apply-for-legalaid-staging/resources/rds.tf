/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "apply-for-legal-aid-rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.0"

  vpc_name                 = var.vpc_name
  team_name                = "apply-for-legal-aid"
  business_unit            = "laa"
  application              = "laa-apply-for-legal-aid"
  is_production            = "false"
  namespace                = var.namespace
  environment_name         = "staging"
  infrastructure_support   = "apply-for-civil-legal-aid@digital.justice.gov.uk"
  db_engine                = "postgres"
  db_engine_version        = "14"
  db_instance_class        = "db.t4g.small"
  db_name                  = "apply_for_legal_aid_staging"
  rds_family               = "postgres14"
  db_max_allocated_storage = "500"

  snapshot_identifier = "rds:cloud-platform-464651662c253592-2022-03-03-05-40"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "apply-for-legal-aid-rds" {
  metadata {
    name      = "apply-for-legal-aid-rds-instance-output"
    namespace = "laa-apply-for-legalaid-staging"
  }

  data = {
    rds_instance_endpoint = module.apply-for-legal-aid-rds.rds_instance_endpoint
    database_name         = module.apply-for-legal-aid-rds.database_name
    database_username     = module.apply-for-legal-aid-rds.database_username
    database_password     = module.apply-for-legal-aid-rds.database_password
    rds_instance_address  = module.apply-for-legal-aid-rds.rds_instance_address
    url                   = "postgres://${module.apply-for-legal-aid-rds.database_username}:${module.apply-for-legal-aid-rds.database_password}@${module.apply-for-legal-aid-rds.rds_instance_endpoint}/${module.apply-for-legal-aid-rds.database_name}"
  }
}
