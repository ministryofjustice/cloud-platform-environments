module "aurora_db" {
  # always check the latest release in Github and set below
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-aurora?ref=3.0.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # Database configuration
  engine         = "aurora-postgresql"
  engine_version = "14.9"
  engine_mode    = "provisioned"
  instance_type  = "db.t4g.medium"
  replica_count  = 1

  performance_insights_enabled = true
  allow_major_version_upgrade  = true

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "aurora_db" {
  metadata {
    name      = "aurora-db-secret"
    namespace = "abundant-namespace-dev"
  }

  data = {
    rds_cluster_endpoint        = module.aurora_db.rds_cluster_endpoint
    rds_cluster_reader_endpoint = module.aurora_db.rds_cluster_reader_endpoint
    db_cluster_identifier       = module.aurora_db.db_cluster_identifier
    database_name               = module.aurora_db.database_name
    database_username           = module.aurora_db.database_username
    database_password           = module.aurora_db.database_password
  }
}
