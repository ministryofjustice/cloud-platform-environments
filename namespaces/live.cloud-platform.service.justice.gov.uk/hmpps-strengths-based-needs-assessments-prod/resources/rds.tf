
module "hmpps_strengths_based_needs_assessments_prod_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  rds_family             = "postgres15"
  db_instance_class      = "db.t4g.small"
  db_engine              = "postgres"
  db_engine_version      = "15"

  allow_major_version_upgrade = "true"
  prepare_for_major_upgrade = false

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_strengths_based_needs_assessments_prod_rds_secret" {
  metadata {
    name      = "hmpps-strengths-based-needs-assessments-rds-instance"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps_strengths_based_needs_assessments_prod_rds.rds_instance_endpoint
    database_name         = module.hmpps_strengths_based_needs_assessments_prod_rds.database_name
    database_username     = module.hmpps_strengths_based_needs_assessments_prod_rds.database_username
    database_password     = module.hmpps_strengths_based_needs_assessments_prod_rds.database_password
    rds_instance_address  = module.hmpps_strengths_based_needs_assessments_prod_rds.rds_instance_address
    url                   = "postgres://${module.hmpps_strengths_based_needs_assessments_prod_rds.database_username}:${module.hmpps_strengths_based_needs_assessments_prod_rds.database_password}@${module.hmpps_strengths_based_needs_assessments_prod_rds.rds_instance_endpoint}/${module.hmpps_strengths_based_needs_assessments_prod_rds.database_name}"
  }
}
