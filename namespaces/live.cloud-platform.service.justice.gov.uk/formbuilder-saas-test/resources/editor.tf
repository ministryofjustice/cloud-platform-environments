module "editor-rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.19.0"

  vpc_name                   = var.vpc_name
  db_backup_retention_period = var.db_backup_retention_period
  application                = "formbuilder-editor"
  environment-name           = var.environment_name
  is-production              = var.is_production
  namespace                  = var.namespace
  infrastructure-support     = var.infrastructure_support
  team_name                  = var.team_name
  db_engine_version          = "12"
  rds_family                 = "postgres12"
  db_instance_class          = var.db_instance_class

  providers = {
    aws = aws.london
  }
}

module "editor-json-output-s3-irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name = var.eks_cluster_name

  service_account_name = "formbuilder-editor-test" # match existing service account defined in editor-service-account.yaml
  namespace            = var.namespace # this is also used as a tag

  role_policy_arns = {
    jsonS3 = data.kubernetes_secret.json-output-s3-secret.data.json-output-s3-arn
  }

  team_name              = var.team_name
  business_unit          = "transformed-department"
  application            = "formbuilder-editor"
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

data "kubernetes_secret" "json-output-s3-secret" {
  metadata {
    name      = "json-output-s3-arn"
    namespace = var.namespace
  }
}

resource "kubernetes_secret" "editor-rds-instance" {
  metadata {
    name      = "rds-instance-formbuilder-editor-${var.environment_name}"
    namespace = "formbuilder-saas-${var.environment_name}"
  }

  data = {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.editor-rds-instance.database_username}:${module.editor-rds-instance.database_password}@${module.editor-rds-instance.rds_instance_endpoint}/${module.editor-rds-instance.database_name}"
  }
}
