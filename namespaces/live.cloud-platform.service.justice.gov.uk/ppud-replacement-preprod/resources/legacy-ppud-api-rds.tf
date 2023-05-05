##
## SQL Server - Lumen/PPUD Copy
##

module "ppud_replica_preprod_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.18.0"

  vpc_name               = var.vpc_name
  namespace              = var.namespace
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  team_name              = var.team_name

  rds_name             = "ppud-replica-preprod"
  rds_family           = "sqlserver-web-14.0"
  db_engine            = "sqlserver-web"
  db_engine_version    = "14.00"
  db_instance_class    = "db.t3.small"
  db_allocated_storage = "100"
  license_model        = "license-included"
  option_group_name    = aws_db_option_group.ppud_replica_rds_option_group.name

  db_parameter = [
    {
      name         = "rds.force_ssl"
      value        = "1"
      apply_method = "pending-reboot"
    }
  ]
  providers = {
    aws = aws.london
  }
}

resource "aws_db_option_group" "ppud_replica_rds_option_group" {
  name                     = "ppud-replica-preprod"
  option_group_description = "Enable SQL Server Backup/Restore"
  engine_name              = "sqlserver-web"
  major_engine_version     = "14.00"

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
