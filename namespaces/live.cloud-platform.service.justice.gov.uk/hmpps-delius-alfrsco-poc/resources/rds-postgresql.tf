/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "rds_alfresco" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.0"

  # VPC configuration
  vpc_name = var.vpc_name

  db_name = "alfresco"

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  db_allocated_storage         = 200
  # enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # PostgreSQL specifics
  db_engine         = "postgres"
  prepare_for_major_upgrade = true
  db_engine_version = "14.10"
  rds_family        = "postgres14"
  db_instance_class = "db.t3.micro"

  # Tagst
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

# To create a read replica, use the below code and update the values to specify the RDS instance
# from which you are replicating. In this example, we're assuming that rds is the
# source RDS instance and read-replica is the replica we are creating.

module "read_replica" {
  # default off
  count  = 0
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.0"

  vpc_name = var.vpc_name

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  # If any other inputs of the RDS is passed in the source db which are different from defaults,
  # add them to the replica

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "14"
  rds_family        = "postgres14"
  db_instance_class = "db.t3.micro"
  # It is mandatory to set the below values to create read replica instance

  # Set the database_name of the source db
  db_name = null # "db_name": conflicts with replicate_source_db

  # Set the db_identifier of the source db
  replicate_source_db = module.rds_alfresco.db_identifier

  # Set to true. No backups or snapshots are created for read replica
  skip_final_snapshot        = "true"
  db_backup_retention_period = 0

  # If db_parameter is specified in source rds instance, use the same values.
  # If not specified you dont need to add any. It will use the default values.

  # db_parameter = [
  #   {
  #     name         = "rds_alfresco.force_ssl"
  #     value        = "0"
  #     apply_method = "immediate"
  #   }
  # ]
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-alf-psql-instance-output"
    namespace = var.namespace
  }

  data = {
    RDS_INSTANCE_ENDPOINT = module.rds_alfresco.rds_instance_endpoint
    DATABASE_NAME         = module.rds_alfresco.database_name
    DATABASE_USERNAME     = module.rds_alfresco.database_username
    DATABASE_PASSWORD     = module.rds_alfresco.database_password
    RDS_INSTANCE_ADDRESS  = module.rds_alfresco.rds_instance_address
  }
  /* You can replace all of the above with the following, if you prefer to
     * use a single database URL value in your application code:
     *
     * url = "postgres://${module.rds_alfresco.database_username}:${module.rds_alfresco.database_password}@${module.rds_alfresco.rds_instance_endpoint}/${module.rds_alfresco.database_name}"
     *
     */
}


resource "kubernetes_secret" "read_replica" {
  # default off
  count = 0

  metadata {
    name      = "rds-alf-psql-read-replica-output"
    namespace = var.namespace
  }

  # The database_username, database_password, database_name values are same as the source RDS instance.
  # Uncomment if count > 0

  /*
  data = {
    rds_instance_endpoint = module.read_replica.rds_instance_endpoint
    rds_instance_address  = module.read_replica.rds_instance_address
    access_key_id         = module.read_replica.access_key_id
    secret_access_key     = module.read_replica.secret_access_key
  }
  */
}


# Configmap to store non-sensitive data related to the RDS instance

resource "kubernetes_config_map" "rds_alfresco" {
  metadata {
    name      = "rds-alf-pgsql-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds_alfresco.database_name
    db_identifier = module.rds_alfresco.db_identifier
  }
}
