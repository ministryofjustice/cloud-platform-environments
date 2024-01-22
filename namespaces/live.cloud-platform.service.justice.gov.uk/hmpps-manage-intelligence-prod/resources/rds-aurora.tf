module "rds_aurora" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-aurora?ref=3.0.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # Database configuration
  engine         = "aurora-postgresql"
  engine_version = "15.5"
  engine_mode    = "provisioned"
  instance_type  = "db.serverless"
  serverlessv2_scaling_configuration = {
    min_capacity = 5
    max_capacity = 40
  }
  replica_count                = 1
  performance_insights_enabled = true
  #db_parameter_group_name      = resource.aws_db_parameter_group.default.name
  db_parameter_group_name       = default.aurora-postgres14
  allow_major_version_upgrade  = true

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

# resource "aws_db_parameter_group" "default" {
#   name   = module.rds_aurora.db_cluster_identifier
#   family = "aurora-postgresql14"

#   parameter {
#     name  = "log_error_verbosity"
#     value = "TERSE"
#   }
#   parameter {
#     name  = "work_mem"
#     value = 4096
#   }
#   parameter {
#     name  = "max_parallel_workers_per_gather"
#     value = 4
#   }
# }

resource "random_id" "manage_intelligence_update_role_password" {
  byte_length = 32
}

resource "random_id" "manage_intelligence_read_role_password" {
  byte_length = 32
}

resource "kubernetes_secret" "manage_intelligence_rds_aurora" {
  metadata {
    name      = "manage-intelligence-rds-aurora-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_cluster_endpoint                = module.rds_aurora.rds_cluster_endpoint
    rds_cluster_reader_endpoint         = module.rds_aurora.rds_cluster_reader_endpoint
    db_cluster_identifier               = module.rds_aurora.db_cluster_identifier
    database_name                       = module.rds_aurora.database_name
    database_username                   = module.rds_aurora.database_username
    database_password                   = module.rds_aurora.database_password
    manage_intelligence_update_password = random_id.manage_intelligence_update_role_password.b64_url
    manage_intelligence_read_password   = random_id.manage_intelligence_read_role_password.b64_url
    url                                 = "postgres://${module.rds_aurora.database_username}:${module.rds_aurora.database_password}@${module.rds_aurora.rds_cluster_endpoint}/${module.rds_aurora.database_name}"
    reader_url                          = "postgres://${module.rds_aurora.database_username}:${module.rds_aurora.database_password}@${module.rds_aurora.rds_cluster_reader_endpoint}/${module.rds_aurora.database_name}"
  }
}
