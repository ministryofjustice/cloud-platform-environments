module "hmpps_service_catalogue_strapi5" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
  db_allocated_storage        = 10
  storage_type                = "gp2"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = "hmpps-service-catalogue-strapi5"
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support
  allow_major_version_upgrade = "false"
  db_instance_class           = "db.t4g.micro"
  db_max_allocated_storage    = "500" # maximum storage for autoscaling
  db_engine_version           = "17"
  rds_family                  = "postgres17"

  providers = {
    aws = aws.london
  }

}

resource "kubernetes_secret" "hmpps_service_catalogue_strapi5" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps_service_catalogue_strapi5.rds_instance_endpoint
    database_name         = module.hmpps_service_catalogue_strapi5.database_name
    database_username     = module.hmpps_service_catalogue_strapi5.database_username
    database_password     = module.hmpps_service_catalogue_strapi5.database_password
    rds_instance_address  = module.hmpps_service_catalogue_strapi5.rds_instance_address
  }
}

resource "kubernetes_secret" "hmpps_service_catalogue_strapi5-dev" {
  metadata {
    name      = "rds-instance-output-dev"
    namespace = "hmpps-portfolio-management-prod"
  }

  data = {
    rds_instance_endpoint = module.hmpps_service_catalogue_strapi5.rds_instance_endpoint
    database_name         = module.hmpps_service_catalogue_strapi5.database_name
    database_username     = module.hmpps_service_catalogue_strapi5.database_username
    database_password     = module.hmpps_service_catalogue_strapi5.database_password
    rds_instance_address  = module.hmpps_service_catalogue_strapi5.rds_instance_address
  }
}

########################################################################################################
#if there are multiple databases provisioned, then those names should be added in local variable as well. Like
#rds_databases = {
# "rdsAlertsDatabases.${module.hmpps_service_catalogue1.db_identifier1}" = "hmpps-service-catalogue-db1"
# "rdsAlertsDatabases.${module.hmpps_service_catalogue2.db_identifier2}" = "hmpps-service-catalogue-db2"
#}
########################################################################################################## 

locals {

  rds_databases = {
    "rdsAlertsDatabases.${module.hmpps_service_catalogue_strapi5.db_identifier}" = "hmpps-service-catalogue-db"

  }

  database_list = flatten([
    for identifier, desc in local.rds_databases : {
      identifier = identifier
      desc       = desc
    }
  ])

  database_details = {
    for m in local.database_list : (m.identifier) => m
  }
}

resource "helm_release" "generic-aws-prometheus-alerts" {
  name       = "generic-aws-prometheus-alerts"
  repository = "https://ministryofjustice.github.io/hmpps-helm-charts"
  chart      = "generic-aws-prometheus-alerts"
  version    = "1.0.1"
  namespace  = var.namespace

  set {
    name  = "targetApplication"
    value = "hmpps-service-catalogue"
  }

  set {
    name  = "alertSeverity"
    value = "digital-prison-service-dev"
  }

  dynamic "set" {
    for_each = local.database_details
    content {
      name  = set.value["identifier"]
      value = set.value["desc"]
    }
  }
}








