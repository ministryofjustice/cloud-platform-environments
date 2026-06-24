module "arns_assessment_view_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  prepare_for_major_upgrade    = false
  performance_insights_enabled = false
  deletion_protection          = true
  db_max_allocated_storage     = "500"
  enable_rds_auto_start_stop   = true

  # PostgreSQL specifics
  db_allocated_storage = 80
  storage_type         = "gp3"
  rds_family           = "postgres18"
  db_engine            = "postgres"
  db_engine_version    = "18"
  db_instance_class    = "db.t4g.micro"

  # Tags
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  # Name
  rds_name = "hmpps-arns-assessment-view-db-${var.environment}"

  enable_irsa = true

  vpc_security_group_ids = [data.aws_security_group.mp_dps_sg.id]

  db_parameter = [
    {
      name         = "rds.force_ssl"
      value        = "1"
      apply_method = "pending-reboot"
    },
    {
      name         = "shared_preload_libraries"
      value        = "pglogical"
      apply_method = "pending-reboot"
    },
    {
      name         = "rds.logical_replication"
      value        = "1"
      apply_method = "pending-reboot"
    },
    {
      name         = "max_wal_size"
      value        = "1024" # 1024MB / 1GB
      apply_method = "immediate"
    },
    {
      name         = "wal_sender_timeout"
      value        = "0"
      apply_method = "immediate"
    },
    {
      name         = "max_slot_wal_keep_size"
      value        = "40000" # 40,000MB / 40GB
      apply_method = "immediate"
    }
  ]

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "arns_assessment_view_rds" {
  metadata {
    name      = "rds-arns-assessment-view-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.arns_assessment_view_rds.rds_instance_endpoint
    database_name         = module.arns_assessment_view_rds.database_name
    database_username     = module.arns_assessment_view_rds.database_username
    database_password     = module.arns_assessment_view_rds.database_password
    rds_instance_address  = module.arns_assessment_view_rds.rds_instance_address
    url                   = "postgres://${module.arns_assessment_view_rds.database_username}:${module.arns_assessment_view_rds.database_password}@${module.arns_assessment_view_rds.rds_instance_endpoint}/${module.arns_assessment_view_rds.database_name}"
  }
}

# Retrieve mp_dps_sg_name SG group ID, CP-MP-INGRESS
data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}

locals {
  dpr_db_secret = {
    username           = postgresql_role.digital_prison_reporting_user.name
    user               = postgresql_role.digital_prison_reporting_user.name
    password           = random_password.dpr_password.result
    endpoint           = module.arns_assessment_view_rds.rds_instance_address
    heartbeat_endpoint = "" # should be blank, unless we later add a read replica
    port               = module.arns_assessment_view_rds.rds_instance_port
    db_name            = module.arns_assessment_view_rds.database_name
  }

  dpr_secret_arn = "arn:aws:secretsmanager:eu-west-2:771283872747:secret:external/dpr-pr-assess-view-source-secrets-60gnIi"
}

resource "kubernetes_secret_v1" "db_credentials" {
  metadata {
    name      = "dpr-db-credentials"
    namespace = var.namespace
  }

  type = "Opaque"

  data = {
    for key, value in local.dpr_db_secret :
    key => tostring(value)
  }
}

# Provider settings for creating the role.
provider "postgresql" {
  database         = module.arns_assessment_view_rds.database_name
  host             = module.arns_assessment_view_rds.rds_instance_address
  port             = module.arns_assessment_view_rds.rds_instance_port
  username         = module.arns_assessment_view_rds.database_username
  password         = module.arns_assessment_view_rds.database_password
  expected_version = "18"
  sslmode          = "require"
  superuser        = false
}

# DPR User Data
resource "random_password" "dpr_password" {
  length  = 16
  special = false

  keepers = {
    last_changed = "2026-05-27"
  }
}

resource "postgresql_role" "digital_prison_reporting_user" {
  name     = "digital_prison_reporting_user"
  login    = true
  password = random_password.dpr_password.result
}

resource "postgresql_grant_role" "digital_prison_reporting_user_rds_superuser" {
  role       = postgresql_role.digital_prison_reporting_user.name
  grant_role = "rds_superuser"
}

resource "postgresql_grant_role" "digital_prison_reporting_user_rds_replication" {
  role       = postgresql_role.digital_prison_reporting_user.name
  grant_role = "rds_replication"
}

# resource "aws_secretsmanager_secret_version" "db" {
#   provider  = aws.secrets
#   secret_id = local.dpr_secret_arn
#
#   secret_string = jsonencode(local.dpr_db_secret)
# }
