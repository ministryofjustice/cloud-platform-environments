module "drupal_rds" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.0.1"
  vpc_name                   = var.vpc_name
  team_name                  = var.team_name
  business_unit              = var.business_unit
  application                = var.application
  is_production              = var.is_production
  namespace                  = var.namespace
  environment_name           = var.environment-name
  infrastructure_support     = var.infrastructure_support
  db_instance_class          = "db.t4g.medium"
  enable_rds_auto_start_stop = true


  snapshot_identifier = "rds:cloud-platform-2703fa2c8a00ad83-2020-10-16-04-52"

  db_engine                = "mariadb"
  db_engine_version        = "10.11"
  rds_family               = "mariadb10.11"
  db_password_rotated_date = "2023-03-22"

  # The recommended transaction isolation level for Drupal is READ-COMMITTED.
  # See https://www.drupal.org/docs/getting-started/system-requirements/setting-the-mysql-transaction-isolation-level
  db_parameter = [
    {
      name         = "tx_isolation"
      value        = "READ-COMMITTED"
      apply_method = "immediate"
    }
  ]
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
  }
}

# This places a secret for this dev RDS instance in the production namespace,
# this can then be used by a kubernetes job which will refresh the dev data.
resource "kubernetes_secret" "drupal_rds_refresh_creds_development" {
  metadata {
    name      = "drupal-rds-instance-output-development"
    namespace = "prisoner-content-hub-production"
  }

  data = {
    rds_instance_endpoint = module.drupal_rds.rds_instance_endpoint
    database_name         = module.drupal_rds.database_name
    database_username     = module.drupal_rds.database_username
    database_password     = module.drupal_rds.database_password
    rds_instance_address  = module.drupal_rds.rds_instance_address
  }
}

module "prisoner_feedback_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.0.1"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  allow_major_version_upgrade = "false"
  allow_minor_version_upgrade = "true"
  prepare_for_major_upgrade   = false
  db_engine                   = "postgres"
  db_engine_version           = "17"
  rds_family                  = "postgres17"
  db_instance_class           = "db.t4g.micro"
  db_max_allocated_storage    = "20"
  enable_rds_auto_start_stop   = true
  performance_insights_enabled = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prisoner_feedback_rds" {
  metadata {
    name      = "prisoner-feedback-rds"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.prisoner_feedback_rds.rds_instance_endpoint
    database_name         = module.prisoner_feedback_rds.database_name
    database_username     = module.prisoner_feedback_rds.database_username
    database_password     = module.prisoner_feedback_rds.database_password
    rds_instance_address  = module.prisoner_feedback_rds.rds_instance_address
  }
}
