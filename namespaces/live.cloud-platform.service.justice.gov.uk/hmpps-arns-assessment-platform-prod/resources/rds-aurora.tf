module "rds_aurora" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-aurora?ref=4.3.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # Database configuration
  engine         = "aurora-postgresql"
  engine_version = "16.6"
  engine_mode    = "provisioned"
  instance_type  = "db.serverless"
  replica_count  = 1

  serverlessv2_scaling_configuration = {
    min_capacity = 2
    max_capacity = 16
  }

  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true

  db_name = var.db_name

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "rds_aurora" {
  metadata {
    name      = "rds-aurora-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_cluster_endpoint        = module.rds_aurora.rds_cluster_endpoint
    rds_cluster_reader_endpoint = module.rds_aurora.rds_cluster_reader_endpoint
    db_cluster_identifier       = module.rds_aurora.db_cluster_identifier
    database_name               = module.rds_aurora.database_name
    database_username           = module.rds_aurora.database_username
    database_password           = module.rds_aurora.database_password
  }
}

resource "kubernetes_config_map" "rds_aurora" {
  metadata {
    name      = "rds-aurora-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name         = module.rds_aurora.database_name
    db_cluster_identifier = module.rds_aurora.db_cluster_identifier
  }
}
