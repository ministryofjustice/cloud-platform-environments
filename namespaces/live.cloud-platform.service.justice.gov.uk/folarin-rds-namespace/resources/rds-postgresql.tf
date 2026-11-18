module "rds_source" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = false # Keep both instances on 16.15
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  enable_rds_auto_start_stop   = true
  db_max_allocated_storage     = "500" # db.t4g.micro allows up to 6 TiB, the module default is 10000 GiB

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "16.15"
  rds_family        = "postgres16"
  db_instance_class = "db.t4g.micro"

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

module "rds_target" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # Restore from a manual snapshot of rds_source, using the ARN so the snapshot copy is not replaced on every apply
  snapshot_identifier = "arn:aws:rds:eu-west-2:754256621582:snapshot:folarin-rds-source-pg16-11-11-2026"
  is_migration        = true # Copy the snapshot and encrypt it with this module's KMS key
  db_name             = null # Inherit the database name from the snapshot

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = false # Keep both instances on 16.15
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  enable_rds_auto_start_stop   = true
  db_max_allocated_storage     = "500" # db.t4g.micro allows up to 6 TiB, the module default is 10000 GiB

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "16.15"
  rds_family        = "postgres16"
  db_instance_class = "db.t4g.micro"

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "kubernetes_secret" "rds_source" {
  metadata {
    name      = "rds-postgresql-source-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_source.rds_instance_endpoint
    database_name         = module.rds_source.database_name
    database_username     = module.rds_source.database_username
    database_password     = module.rds_source.database_password
    rds_instance_address  = module.rds_source.rds_instance_address
  }
}

resource "kubernetes_secret" "rds_target" {
  metadata {
    name      = "rds-postgresql-target-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_target.rds_instance_endpoint
    database_name         = module.rds_target.database_name
    database_username     = module.rds_target.database_username
    database_password     = module.rds_target.database_password
    rds_instance_address  = module.rds_target.rds_instance_address
  }
}

resource "kubernetes_config_map" "rds_source" {
  metadata {
    name      = "rds-postgresql-source-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds_source.database_name
    db_identifier = module.rds_source.db_identifier
  }
}

resource "kubernetes_config_map" "rds_target" {
  metadata {
    name      = "rds-postgresql-target-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds_target.database_name
    db_identifier = module.rds_target.db_identifier
  }
}
