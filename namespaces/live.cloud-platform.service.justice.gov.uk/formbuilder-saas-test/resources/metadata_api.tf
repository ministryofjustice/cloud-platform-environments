module "metadata-api-rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"

  vpc_name                   = var.vpc_name
  db_backup_retention_period = var.db_backup_retention_period
  application                = "formbuilder-metadata-api"
  environment_name           = var.environment_name
  is_production              = var.is_production
  namespace                  = var.namespace
  infrastructure_support     = var.infrastructure_support
  team_name                  = var.team_name
  business_unit              = "Platforms"
  prepare_for_major_upgrade  = false
  db_engine_version          = "15.5"
  rds_family                 = "postgres15"
  db_instance_class          = var.db_instance_class

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "metadata-api-rds-instance" {
  metadata {
    name      = "rds-instance-formbuilder-metadata-api-${var.environment_name}"
    namespace = "formbuilder-saas-${var.environment_name}"
  }

  data = {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.metadata-api-rds-instance.database_username}:${module.metadata-api-rds-instance.database_password}@${module.metadata-api-rds-instance.rds_instance_endpoint}/${module.metadata-api-rds-instance.database_name}"
  }
}

locals {
  metadata_api_sa_name = "formbuilder-terraform-metadata-api-test"
}


resource "kubernetes_service_account" "metadata_api_service_account" {
  metadata {
    name      = local.metadata_api_sa_name
    namespace = var.namespace
  }

  secret {
    name = "${local.metadata_api_sa_name}-token"
  }

  automount_service_account_token = true
}

resource "kubernetes_secret_v1" "metadata_api_service_account_token" {
  metadata {
    name      = "${local.metadata_api_sa_name}-token"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/service-account.name" = local.metadata_api_sa_name
    }
  }

  type = "kubernetes.io/service-account-token"

  depends_on = [
    kubernetes_service_account.metadata_api_service_account
  ]
}