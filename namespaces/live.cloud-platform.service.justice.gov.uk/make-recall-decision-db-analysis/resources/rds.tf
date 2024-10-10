module "make_recall_decision_db_analysis_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=7.3.1"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  db_engine              = "sqlserver-ex"
  db_engine_version      = "16.00"
  db_instance_class      = "db.t3.small"
  db_allocated_storage   = 20
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  rds_family             = "sqlserver-ex-16.0"
  db_parameter           = []
  license_model          = "license-included"
  prepare_for_major_upgrade = false

  performance_insights_enabled = true

  option_group_name    = aws_db_option_group.sqlserver_backup_rds_option_group.name


  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "make_recall_decision_db_analysis_rds" {
  metadata {
    name      = "rds-sqlserver-instance-output"
    namespace = var.namespace
  }

  data = {
    DB_SERVER   = module.make_recall_decision_db_analysis_rds.rds_instance_endpoint
    DB_USER     = module.make_recall_decision_db_analysis_rds.database_username
    DB_PASS     = module.make_recall_decision_db_analysis_rds.database_password
    DB_NAME     = "PPUD_Dev"
    rds_instance_address  = module.make_recall_decision_db_analysis_rds.rds_instance_address
  }
}

resource "aws_db_option_group" "sqlserver_backup_rds_option_group" {
  name                     = "sqlserver-backup"
  option_group_description = "Enable SQL Server Backup/Restore"
  engine_name              = "sqlserver-ex"
  major_engine_version     = "16.00"

  option {
    option_name = "SQLSERVER_BACKUP_RESTORE"

    option_settings {
      name  = "IAM_ROLE_ARN"
      value = aws_iam_role.ppud_backup_s3_iam_role.arn
    }
  }
}