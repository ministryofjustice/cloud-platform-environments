module "publisher-rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"

  vpc_name                    = var.vpc_name
  db_backup_retention_period  = var.db_backup_retention_period
  application                 = "formbuilderpublisher"
  environment_name            = var.environment-name
  is_production               = var.is_production
  namespace                   = var.namespace
  infrastructure_support      = var.infrastructure_support
  team_name                   = var.team_name
  business_unit               = var.business_unit
  db_engine_version           = "12"
  allow_major_version_upgrade = "true"
  rds_family                  = "postgres12"
  db_instance_class           = "db.t4g.small"

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
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.0.0"

  vpc_name               = var.vpc_name
  application            = "formbuilderpublisher"
  environment_name       = var.environment-name
  is_production          = var.is_production
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  business_unit          = var.business_unit
  engine_version         = "7.0"
  parameter_group_name   = "default.redis7"
  node_type              = "cache.t4g.medium"
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
