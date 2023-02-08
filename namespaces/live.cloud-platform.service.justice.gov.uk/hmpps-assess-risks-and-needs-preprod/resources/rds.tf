
module "hmpps_assess_risks_and_needs_preprod_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.16"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support
  rds_family             = "postgres14"
  db_instance_class      = "db.t3.small"
  db_engine              = "postgres"
  db_engine_version      = "14"

  allow_major_version_upgrade = "true"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_assess_risks_and_needs_preprod_rds_secret" {
  metadata {
    name      = "hmpps-assess-risks-and-needs-rds-instance"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps_assess_risks_and_needs_preprod_rds.rds_instance_endpoint
    database_name         = module.hmpps_assess_risks_and_needs_preprod_rds.database_name
    database_username     = module.hmpps_assess_risks_and_needs_preprod_rds.database_username
    database_password     = module.hmpps_assess_risks_and_needs_preprod_rds.database_password
    rds_instance_address  = module.hmpps_assess_risks_and_needs_preprod_rds.rds_instance_address
    access_key_id         = module.hmpps_assess_risks_and_needs_preprod_rds.access_key_id
    secret_access_key     = module.hmpps_assess_risks_and_needs_preprod_rds.secret_access_key
    url                   = "postgres://${module.hmpps_assess_risks_and_needs_preprod_rds.database_username}:${module.hmpps_assess_risks_and_needs_preprod_rds.database_password}@${module.hmpps_assess_risks_and_needs_preprod_rds.rds_instance_endpoint}/${module.hmpps_assess_risks_and_needs_preprod_rds.database_name}"
  }
}

# Inject pre-prod DB credentials for refresh job running on production
resource "kubernetes_secret" "hmpps_assess_risks_and_needs_prod_refresh_secret" {
  metadata {
    name      = "preprod-rds-instance"
    namespace = "hmpps-assess-risks-and-needs-prod"
  }

  data = {
    rds_instance_endpoint = module.hmpps_assess_risks_and_needs_preprod_rds.rds_instance_endpoint
    database_name         = module.hmpps_assess_risks_and_needs_preprod_rds.database_name
    database_username     = module.hmpps_assess_risks_and_needs_preprod_rds.database_username
    database_password     = module.hmpps_assess_risks_and_needs_preprod_rds.database_password
    rds_instance_address  = module.hmpps_assess_risks_and_needs_preprod_rds.rds_instance_address
    access_key_id         = module.hmpps_assess_risks_and_needs_preprod_rds.access_key_id
    secret_access_key     = module.hmpps_assess_risks_and_needs_preprod_rds.secret_access_key
    url                   = "postgres://${module.hmpps_assess_risks_and_needs_preprod_rds.database_username}:${module.hmpps_assess_risks_and_needs_preprod_rds.database_password}@${module.hmpps_assess_risks_and_needs_preprod_rds.rds_instance_endpoint}/${module.hmpps_assess_risks_and_needs_preprod_rds.database_name}"
  }
}
