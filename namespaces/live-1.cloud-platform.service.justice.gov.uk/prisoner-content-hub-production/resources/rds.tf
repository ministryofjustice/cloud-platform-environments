variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

module "drupal_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.3"
  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  force_ssl              = "true"

  db_engine              = "mariadb"
  db_engine_version      = "10.4"
  rds_family             = "mariadb10.4"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "drupal_rds" {
  metadata {
    name      = "drupal-rds"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.drupal_rds.rds_instance_endpoint
    database_name         = module.drupal_rds.database_name
    database_username     = module.drupal_rds.database_username
    database_password     = module.drupal_rds.database_password
    rds_instance_address  = module.drupal_rds.rds_instance_address
    access_key_id         = module.drupal_rds.access_key_id
    secret_access_key     = module.drupal_rds.secret_access_key
    url                   = "postgres://${module.drupal_rds.database_username}:${module.drupal_rds.database_password}@${module.drupal_rds.rds_instance_endpoint}/${module.drupal_rds.database_name}"
  }
}

