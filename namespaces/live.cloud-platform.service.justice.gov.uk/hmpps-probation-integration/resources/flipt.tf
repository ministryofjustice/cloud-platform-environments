module "flipt-db" {
  source                       = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name                     = var.vpc_name
  team_name                    = var.team_name
  business_unit                = var.business_unit
  application                  = var.application
  is_production                = var.is_production
  environment_name             = var.environment
  infrastructure_support       = var.infrastructure_support
  namespace                    = var.namespace
  rds_name                     = "probation-integration-flipt-db"
  rds_family                   = "postgres14"
  db_engine_version            = "14.10"
  db_instance_class            = "db.t4g.small"
  allow_major_version_upgrade  = false
  performance_insights_enabled = true
  maintenance_window = var.maintenance_window
}

resource "kubernetes_secret" "flipt-db" {
  metadata {
    name      = "flipt-db"
    namespace = var.namespace
  }
  data = {
    URL = "postgres://${module.flipt-db.database_username}:${module.flipt-db.database_password}@${module.flipt-db.rds_instance_endpoint}/${module.flipt-db.database_name}"
  }
}

resource "random_password" "flipt-client-token" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "flipt-client" {
  for_each = toset([
    var.namespace,
    "hmpps-probation-integration-services-dev",
    "hmpps-probation-integration-services-preprod",
    "hmpps-probation-integration-services-prod",
  ])
  metadata {
    name      = "flipt-client"
    namespace = each.value
  }
  data = {
    TOKEN = random_password.flipt-client-token.result
  }
}
