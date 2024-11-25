# Deleted visit-scheduler-rds, secret, and db restore password
# To be re-built and restored from pg_dump in a separate PR soon after this one
# see https://dsdmoj.atlassian.net/wiki/spaces/PSCH/pages/5269618719/Database+downsizing

module "prison_visit_booker_registry_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.0.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  allow_major_version_upgrade = "false"
  prepare_for_major_upgrade   = false
  db_engine                   = "postgres"
  db_engine_version           = "15.7"
  rds_family                  = "postgres15"
  db_instance_class           = "db.t4g.small"
  db_password_rotated_date    = "2023-03-22"

  performance_insights_enabled = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prison_visit_booker_registry_rds" {
  metadata {
    name      = "prison-visit-booker-registry-rds"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.prison_visit_booker_registry_rds.rds_instance_endpoint
    database_name         = module.prison_visit_booker_registry_rds.database_name
    database_username     = module.prison_visit_booker_registry_rds.database_username
    database_password     = module.prison_visit_booker_registry_rds.database_password
    rds_instance_address  = module.prison_visit_booker_registry_rds.rds_instance_address
  }
}
