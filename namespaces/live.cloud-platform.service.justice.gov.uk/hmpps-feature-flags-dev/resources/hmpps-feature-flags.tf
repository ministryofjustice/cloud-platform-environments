module "hmpps-feature-flags" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo = "hmpps-feature-flags"
  application = "hmpps-feature-flags"
  github_team = "hmpps-lead-developers"
  environment = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  is_production                 = var.is_production
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  reviewer_teams                = ["manage-a-workforce"]
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}


module "flipt-db" {
  source                       = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.0.0"
  db_allocated_storage         = 10
  storage_type                 = "gp2"
  vpc_name                     = var.vpc_name
  team_name                    = var.team_name
  business_unit                = var.business_unit
  application                  = var.application
  is_production                = var.is_production
  environment_name             = var.environment
  infrastructure_support       = var.infrastructure_support
  namespace                    = var.namespace
  rds_name                     = "hmpps-feature-flags-flipt-db-${var.environment}"
  rds_family                   = "postgres16"
  db_engine_version            = "16.8"
  db_instance_class            = "db.t4g.small"
  prepare_for_major_upgrade    = false
  allow_major_version_upgrade  = true
  performance_insights_enabled = true
  maintenance_window           = "sun:00:00-sun:03:00"
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

resource "random_password" "flipt-bootstrap-token" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "flipt-bootstrap-token" {
  metadata {
    name      = "flipt-bootstrap-token"
    namespace = var.namespace
  }
  data = {
    TOKEN = random_password.flipt-bootstrap-token.result
  }
}
