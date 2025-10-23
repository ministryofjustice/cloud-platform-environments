data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

module "rds_security_group" {
  #checkov:skip=CKV_TF_1:Module registry does not support commit hashes for versions
  #checkov:skip=CKV_TF_2:Module registry does not support tags for versions

  source  = "terraform-aws-modules/security-group/aws"
  version = "5.2.0"

  name = "datahub_modernisation_platform_access"

  vpc_id = data.aws_vpc.this.id

  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = "10.27.96.0/21"
    },

  ]
}

module "rds" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  db_allocated_storage = var.db_allocated_storage
  storage_type         = var.storage_type

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = var.allow_minor_version_upgrade
  allow_major_version_upgrade  = var.allow_major_version_upgrade
  prepare_for_major_upgrade    = var.prepare_for_major_upgrade
  performance_insights_enabled = var.performance_insights_enabled
  db_max_allocated_storage     = var.db_max_allocated_storage
  enable_rds_auto_start_stop   = var.enable_rds_auto_start_stop # turn off database overnight 22:00-06:00 UTC.
  maintenance_window = var.maintenance_window
  backup_window = var.backup_window
  db_parameter = var.db_parameter
  
  # PostgreSQL specifics
  db_engine         = var.db_engine
  db_engine_version = var.db_engine_version
  rds_family        = var.rds_family
  db_instance_class = var.db_instance_class

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  # A list of additional VPC security group IDs to associate
  # with the DB instance - in adition to the default VPC security groups
  # granting access from the Cloud Platform
  vpc_security_group_ids = [module.rds_security_group.security_group_id]

  enable_irsa = true
}


resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    rds_instance_address  = module.rds.rds_instance_address
    rds_url               = "jdbc:postgres://${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
  }
}

# Configmap to store non-sensitive data related to the RDS instance
resource "kubernetes_config_map" "rds" {
  metadata {
    name      = "rds-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds.database_name
    db_identifier = module.rds.db_identifier
  }
}
