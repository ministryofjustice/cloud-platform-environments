# /*
#  * Make sure that you use the latest version of the module by changing the
#  * `ref=` value in the `source` attribute to the latest version listed on the
#  * releases page of this repository.
#  *
#  */

module "rds" {
  source                   = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.16"
  vpc_name                 = var.vpc_name
  team_name                = var.team_name
  business-unit            = var.business_unit
  application              = var.application
  is-production            = var.is_production
  environment-name         = var.environment
  infrastructure-support   = var.infrastructure_support
  namespace                = var.namespace
  db_engine                = "mariadb"
  db_allocated_storage     = "5"                      # Default is 10 in the RDS module
  db_max_allocated_storage = "1000"                   # Default is 10000 in the RDS module, which is a value not compatble with the gp2 storage type
  license_model            = "general-public-license" # Make this visible
  db_parameter             = []                       # Ensure no default parameters set (default param in TF module adds a parameter not relevant to MariaDB)

  # If the rds_name is not specified a random name will be generated ( cp-* )
  # Changing the RDS name requires the RDS to be re-created (destroy + create)
  # rds_name             = "my-rds-name"

  # enable performance insights
  performance_insights_enabled = false

  # change the rds version as you see fit.
  db_engine_version = "10.5.16"

  # change the instance class as you see fit.
  db_instance_class = "db.t3.micro" # Just used for a POC at this stage

  # Pick the one that defines the mariadb version the best
  rds_family = "mariadb10.5"

  enable_rds_auto_start_stop = true

  # Some engines can't apply some parameters without a reboot(ex postgres9.x cant apply force_ssl immediate).
  # You will need to specify "pending-reboot" here, as default is set to "immediate".
  # db_parameter = [
  #   {
  #     name         = "rds.force_ssl"
  #     value        = "0"
  #     apply_method = "pending-reboot"
  #   }
  # ]

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "false"
  allow_minor_version_upgrade = "false"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

# To create a read replica, use the below code and update the values to specify the RDS instance
# from which you are replicating. In this example, we're assuming that rds is the
# source RDS instance and read-replica is the replica we are creating.

module "read_replica" {
  # default off
  count  = 0
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.16"

  vpc_name               = var.vpc_name
  application            = var.application
  environment-name       = var.environment
  is-production          = var.is_production
  infrastructure-support = var.infrastructure_support
  team_name              = var.team_name

  # If any other inputs of the RDS is passed in the source db which are different from defaults,
  # add them to the replica

  # It is mandatory to set the below values to create read replica instance

  # Set the database_name of the source db
  db_name = null # "db_name": conflicts with replicate_source_db

  # Set the db_identifier of the source db
  replicate_source_db = module.rds.db_identifier

  # Set to true. No backups or snapshots are created for read replica
  skip_final_snapshot        = "true"
  db_backup_retention_period = 0

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }

  # If db_parameter is specified in source rds instance, use the same values.
  # If not specified you dont need to add any. It will use the default values.

  # db_parameter = [
  #   {
  #     name         = "rds.force_ssl"
  #     value        = "0"
  #     apply_method = "immediate"
  #   }
  # ]
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-mariadb-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    rds_instance_address  = module.rds.rds_instance_address
    access_key_id         = module.rds.access_key_id
    secret_access_key     = module.rds.secret_access_key
  }
  /* You can replace all of the above with the following, if you prefer to
     * use a single database URL value in your application code, e.g.
     *
     * url = "postgres://${module.rds.database_username}:${module.rds.database_password}@${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
     *
     */
}

resource "kubernetes_secret" "read_replica" {
  # default off
  count = 0

  metadata {
    name      = "rds-mariadb-read-replica-output"
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

resource "kubernetes_config_map" "rds" {
  metadata {
    name      = "rds-mariadb-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds.database_name
    db_identifier = module.rds.db_identifier
  }
}

