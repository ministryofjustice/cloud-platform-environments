#############################################
# Parliamentary Questions (postgres engine) #
#############################################

module "rds_instance" {
  allow_major_version_upgrade = "true"
  application                 = var.application
  cluster_name                = var.cluster_name
  cluster_state_bucket        = var.cluster_state_bucket
  db_backup_retention_period  = var.db_backup_retention_period
  db_engine                   = "postgres"
  db_engine_version           = "12.3"
  db_name                     = "parliamentary_questions_dev"
  environment-name            = var.environment-name
  infrastructure-support      = var.infrastructure-support
  is-production               = var.is-production
  namespace                   = var.namespace
  rds_family                  = "postgres12"
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.12"
  team_name                   = var.team_name
}

resource "kubernetes_secret" "rds_instance" {
  metadata {
    name      = "parliamentary-questions-development-rds"
    namespace = var.namespace
  }

  data = {
    database_name         = module.rds_instance.database_name
    database_password     = module.rds_instance.database_password
    database_username     = module.rds_instance.database_username
    rds_instance_address  = module.rds_instance.rds_instance_address
    rds_instance_endpoint = module.rds_instance.rds_instance_endpoint
    url                   = "postgres://${module.rds_instance.database_username}:${module.rds_instance.database_password}@${module.rds_instance.rds_instance_endpoint}/${module.rds_instance.database_name}"
    access_key_id         = module.rds_instance.access_key_id
    secret_access_key     = module.rds_instance.secret_access_key
  }
}

