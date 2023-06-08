module "aurora_db" {
  # always check the latest release in Github and set below
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-aurora?ref=2.3.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  engine         = "aurora-postgresql"
  engine_version = "14.6"
  engine_mode    = "provisioned"

  instance_type = "db.t4g.medium"
  replica_count = 1

  storage_encrypted            = true
  apply_immediately            = true
  performance_insights_enabled = true
  allow_major_version_upgrade  = true
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
    access_key_id               = module.aurora_db.access_key_id
    secret_access_key           = module.aurora_db.secret_access_key
  }
}
