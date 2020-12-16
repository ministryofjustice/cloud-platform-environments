module "publisher-rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.12"

  cluster_name               = var.cluster_name
  cluster_state_bucket       = var.cluster_state_bucket
  db_backup_retention_period = var.db_backup_retention_period
  application                = "formbuilderpublisher"
  environment-name           = var.environment-name
  is-production              = var.is-production
  namespace                  = var.namespace
  infrastructure-support     = var.infrastructure-support
  team_name                  = var.team_name
  db_engine_version          = "10"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "publisher-rds-instance" {
  metadata {
    name      = "rds-instance-formbuilder-publisher-${var.environment-name}"
    namespace = "formbuilder-publisher-${var.environment-name}"
  }

  data = {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.publisher-rds-instance.database_username}:${module.publisher-rds-instance.database_password}@${module.publisher-rds-instance.rds_instance_endpoint}/${module.publisher-rds-instance.database_name}"
  }
}

##################################################

########################################################
# Publisher Elasticache Redis (for resque + job logging)
module "publisher-elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=4.2"

  cluster_name         = var.cluster_name
  cluster_state_bucket = var.cluster_state_bucket

  application            = "formbuilderpublisher"
  environment-name       = var.environment-name
  is-production          = var.is-production
  infrastructure-support = var.infrastructure-support
  team_name              = var.team_name
  engine_version         = "4.0.10"
  parameter_group_name   = "default.redis4.0"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "publisher-elasticache" {
  metadata {
    name      = "elasticache-formbuilder-publisher-${var.environment-name}"
    namespace = "formbuilder-publisher-${var.environment-name}"
  }

  data = {
    primary_endpoint_address = module.publisher-elasticache.primary_endpoint_address
    auth_token               = module.publisher-elasticache.auth_token
  }
}

