# MySQL, MariaDB, PostgreSQL

module "rds_mysql" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.17.1"

  # VPC configuration
  vpc_name = var.vpc_name
  # vpc_security_group_ids

  allow_major_version_upgrade = false
  allow_minor_version_upgrade = false
  backup_window               = "09:46-10:16"
  # ca_cert_identifier
  # character_set_name
  db_allocated_storage       = "10"
  db_backup_retention_period = "7"
  db_engine                  = "mysql"
  db_engine_version          = "8.0.28" # purposefully an old minor version
  db_instance_class          = "db.t4g.micro"
  # db_iops                    = 0
  db_max_allocated_storage   = "100"
  # db_name
  db_parameter               = []
  db_password_rotated_date   = "2023-04-05"
  deletion_protection        = true
  enable_rds_auto_start_stop = true
  # license_model
  maintenance_window = "Mon:00:00-Mon:03:00"
  # option_group_name
  performance_insights_enabled = true
  rds_family                   = "mysql8.0"
  # rds_name
  # replicate_source_db
  skip_final_snapshot = false
  # snapshot_identifier

  # Tags
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

module "rds_mariadb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.17.1"

  # VPC configuration
  vpc_name = var.vpc_name
  # vpc_security_group_ids

  allow_major_version_upgrade = false
  allow_minor_version_upgrade = false
  backup_window               = "03:46-04:16"
  # ca_cert_identifier
  # character_set_name
  db_allocated_storage       = "10"
  db_backup_retention_period = "7"
  db_engine                  = "mariadb"
  db_engine_version          = "10.6.8" # purposefully an old minor version - mariadb does not follow semver ("10.6" is the major version, ".8" is the minor version)
  db_instance_class          = "db.t4g.micro"
  # db_iops                    = 0
  db_max_allocated_storage   = "100"
  # db_name
  db_parameter               = []
  db_password_rotated_date   = "2023-04-05"
  deletion_protection        = true
  enable_rds_auto_start_stop = true
  # license_model
  maintenance_window = "Mon:00:00-Mon:03:00"
  # option_group_name
  performance_insights_enabled = true
  rds_family                   = "mariadb10.6"
  # rds_name
  # replicate_source_db
  skip_final_snapshot = false
  # snapshot_identifier

  # Tags
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

module "rds_postgresql" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.17.1"

  # VPC configuration
  vpc_name = var.vpc_name
  # vpc_security_group_ids

  allow_major_version_upgrade = false
  allow_minor_version_upgrade = false
  backup_window               = "03:46-04:16"
  # ca_cert_identifier
  # character_set_name
  db_allocated_storage       = "10"
  db_backup_retention_period = "7"
  db_engine                  = "postgres"
  db_engine_version          = "14.3" # purposefully an old minor version
  db_instance_class          = "db.t4g.micro"
  # db_iops                    = 0
  db_max_allocated_storage   = "100"
  # db_name
  db_parameter               = []
  db_password_rotated_date   = "2023-04-05"
  deletion_protection        = true
  enable_rds_auto_start_stop = true
  # license_model
  maintenance_window = "Mon:00:00-Mon:03:00"
  # option_group_name
  performance_insights_enabled = true
  rds_family                   = "postgres14"
  # rds_name
  # replicate_source_db
  skip_final_snapshot = false
  # snapshot_identifier

  # Tags
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}
