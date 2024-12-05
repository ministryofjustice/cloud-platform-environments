
module "hmpps_assess_risks_and_needs_integrations_preprod_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.0.1"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  rds_family             = "postgres16"
  db_instance_class      = "db.t4g.small"
  db_engine              = "postgres"
  db_engine_version      = "16"

  allow_major_version_upgrade = "true"
  prepare_for_major_upgrade = false

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_assess_risks_and_needs_integrations_preprod_rds_secret" {
  metadata {
    name      = "hmpps-assess-risks-and-needs-integrations-rds-instance"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps_assess_risks_and_needs_integrations_preprod_rds.rds_instance_endpoint
    database_name         = module.hmpps_assess_risks_and_needs_integrations_preprod_rds.database_name
    database_username     = module.hmpps_assess_risks_and_needs_integrations_preprod_rds.database_username
    database_password     = module.hmpps_assess_risks_and_needs_integrations_preprod_rds.database_password
    rds_instance_address  = module.hmpps_assess_risks_and_needs_integrations_preprod_rds.rds_instance_address
    url                   = "postgres://${module.hmpps_assess_risks_and_needs_integrations_preprod_rds.database_username}:${module.hmpps_assess_risks_and_needs_integrations_preprod_rds.database_password}@${module.hmpps_assess_risks_and_needs_integrations_preprod_rds.rds_instance_endpoint}/${module.hmpps_assess_risks_and_needs_integrations_preprod_rds.database_name}"
  }
}
