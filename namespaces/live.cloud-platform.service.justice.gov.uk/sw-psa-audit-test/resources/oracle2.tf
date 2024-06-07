module "rds-instance-2" {
  source   = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=migration"
  vpc_name = var.vpc_name

  application            = var.application
  environment_name       = var.environment
  is_production          = var.is_production
  namespace              = var.namespace
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  business_unit          = var.business_unit

  enable_rds_auto_start_stop = true


  # Database configuration
  db_engine                = "oracle-se2" # or oracle-ee
  db_engine_version        = "19.0.0.0.ru-2023-07.rur-2023-07.r1"
  rds_family               = "oracle-se2-19"
  db_instance_class        = "db.t3.medium"
  db_allocated_storage     = "300"
  db_max_allocated_storage = "500"
  db_name                  = "TEST-2"
  license_model            = "license-included"
  db_iops                  = 0
  character_set_name       = "WE8MSWIN1252" # problem
  skip_final_snapshot      = true

  is_migration                = true
  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "false"

  # enable performance insights
  performance_insights_enabled = true

  snapshot_identifier = "arn:aws:rds:eu-west-2:754256621582:snapshot:ccr-sandbox-dev-encrypted-for-cp-dev"

  providers = {
    aws = aws.london
  }

  # passing emplty list as oracle repo has parameter defined
  db_parameter = []
}