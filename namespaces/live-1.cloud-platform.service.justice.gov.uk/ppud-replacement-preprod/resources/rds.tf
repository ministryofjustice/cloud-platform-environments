##
## PostgreSQL - Application Database
##

module "ppud_replacement_preprod_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.5"

  cluster_name           = var.cluster_name
  namespace              = var.namespace
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  team_name              = var.team_name

  rds_name          = "ppud-replacement-preprod"
  rds_family        = "postgres13"
  db_engine         = "postgres"
  db_engine_version = "13"
  db_instance_class = "db.t3.small"
  db_name           = "manage_recalls"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ppud_replacement_preprod_rds_secrets" {
  metadata {
    name      = "manage-recalls-database"
    namespace = var.namespace
  }

  data = {
    host     = module.ppud_replacement_preprod_rds.rds_instance_address
    name     = module.ppud_replacement_preprod_rds.database_name
    username = module.ppud_replacement_preprod_rds.database_username
    password = module.ppud_replacement_preprod_rds.database_password
  }
}

##
## SQL Server - Lumen/PPUD Copy
##

module "ppud_replica_preprod_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.5"

  cluster_name           = var.cluster_name
  namespace              = var.namespace
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  team_name              = var.team_name

  rds_name             = "ppud-replica-preprod"
  rds_family           = "sqlserver-web-11.0"
  db_engine            = "sqlserver-web"
  db_engine_version    = "11.00"
  db_instance_class    = "db.t3.small"
  db_allocated_storage = "100"
  license_model        = "license-included"
  option_group_name    = aws_db_option_group.ppud_replica_rds_option_group.name

  providers = {
    aws = aws.london
  }
}

resource "aws_db_option_group" "ppud_replica_rds_option_group" {
  name                     = "ppud-replica-preprod"
  option_group_description = "Enable SQL Server Backup/Restore"
  engine_name              = "sqlserver-web"
  major_engine_version     = "11.00"

  option {
    option_name = "SQLSERVER_BACKUP_RESTORE"

    option_settings {
      name  = "IAM_ROLE_ARN"
      value = aws_iam_role.lumen_transfer_s3_iam_role.arn # see S3 config for role details
    }
  }
}

resource "kubernetes_secret" "ppud_replica_preprod_rds_secrets" {
  metadata {
    name      = "ppud-replica-database"
    namespace = var.namespace
  }

  data = {
    host     = module.ppud_replica_preprod_rds.rds_instance_address
    name     = "PPUD_LIVE"
    username = module.ppud_replica_preprod_rds.database_username
    password = module.ppud_replica_preprod_rds.database_password
  }
}
