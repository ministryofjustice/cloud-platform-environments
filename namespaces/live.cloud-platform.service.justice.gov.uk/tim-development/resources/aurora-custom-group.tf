module "rds_aurora_custom" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-aurora?ref=4.2.0" # use the latest release

  # VPC configuration
  vpc_name = var.vpc_name

  # Database configuration
  engine         = "aurora-postgresql"
  engine_version = "15.13"
  engine_mode    = "provisioned"
  instance_type  = "db.t4g.medium"
  replica_count  = 1
  # db_parameter_group_name     = resource.aws_db_parameter_group.rds_aurora_custom.name
  # db_parameter_group_name = "default.aurora-postgresql14"
  # db_cluster_parameter_group_name = "default.aurora-postgresql15"
  allow_major_version_upgrade = true
  


  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "rds_aurora_custom" {
  metadata {
    name      = "example-team-rds-cluster-output2"
    namespace = var.namespace
  }

  data = {
    rds_cluster_endpoint        = module.rds_aurora_custom.rds_cluster_endpoint
    rds_cluster_reader_endpoint = module.rds_aurora_custom.rds_cluster_reader_endpoint
    db_cluster_identifier       = module.rds_aurora_custom.db_cluster_identifier
    database_name               = module.rds_aurora_custom.database_name
    database_username           = module.rds_aurora_custom.database_username
    database_password           = module.rds_aurora_custom.database_password
  }
}



resource "aws_db_parameter_group" "rds_aurora_custom" {
  name   = module.rds_aurora_custom.db_cluster_identifier
  family = "aurora-postgresql15"

  lifecycle {
    create_before_destroy = true
  }

  parameter {
    name  = "log_error_verbosity"
    value = "TERSE"
  }
}

