module "rds_aurora" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-aurora?ref=4.3.0" # use the latest release

  # VPC configuration
  vpc_name = var.vpc_name

  # Database configuration
  engine         = "aurora-postgresql"
  engine_version = "15.13"
  engine_mode    = "provisioned"
  instance_type  = "db.t4g.medium"
  replica_count  = 1
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
    name      = "example-team-rds-cluster-output"
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