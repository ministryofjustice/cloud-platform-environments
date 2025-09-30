module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "16" # If you are managing minor version updates, refer to user guide: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/deploying-an-app/relational-databases/upgrade.html#upgrading-a-database-version-or-changing-the-instance-type
  rds_family        = "postgres16"
  db_instance_class = "db.t4g.micro"

  snapshot_identifier = "rds-cloud-platform-a803ab047bcaae23-copy-2025-08-28-10-20"

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

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
  }
}

# module "read_replica" {
#   source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"

#   vpc_name = var.vpc_name

#   # Tags
#   application            = var.application
#   business_unit          = var.business_unit
#   environment_name       = var.environment
#   infrastructure_support = var.infrastructure_support
#   is_production          = var.is_production
#   namespace              = var.namespace
#   team_name              = var.team_name

#   # If any other inputs of the RDS is passed in the source db which are different from defaults,
#   # add them to the replica

#   # PostgreSQL specifics
#   db_engine         = "postgres"
#   db_engine_version = "16" # If you are managing minor version updates, refer to user guide: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/deploying-an-app/relational-databases/upgrade.html#upgrading-a-database-version-or-changing-the-instance-type
#   rds_family        = "postgres16"
#   db_instance_class = "db.t4g.micro"
#   # It is mandatory to set the below values to create read replica instance

#   # Set the db_identifier of the source db
#   replicate_source_db = module.rds.db_identifier

#   # Set to true. No backups or snapshots are created for read replica
#   skip_final_snapshot        = "true"
#   db_backup_retention_period = 0

#   db_max_allocated_storage = "550"

#   # If db_parameter is specified in source rds instance, use the same values.
#   # If not specified you dont need to add any. It will use the default values.

#   # db_parameter = [
#   #   {
#   #     name         = "rds.force_ssl"
#   #     value        = "0"
#   #     apply_method = "immediate"
#   #   }
#   # ]
# }
