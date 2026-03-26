/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  rds_name                     = "restored-from-snapshot"
  snapshot_identifier          = "folarin-dev-restored-from-snapshot-20260325-1616"
  # enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "17.6" # If you are managing minor version updates, refer to user guide: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/deploying-an-app/relational-databases/upgrade.html#upgrading-a-database-version-or-changing-the-instance-type
  rds_family        = "postgres17"
  db_instance_class = "db.t4g.micro"

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  # If you want to assign AWS permissions to a k8s pod in your namespace - ie service pod for CLI queries,
  # uncomment below:

  # enable_irsa = true

  # If you want to enable Cloudwatch logging for this postgres RDS instance, uncomment the code below:
  # opt_in_xsiam_logging = true
}

# Cross-DB restore test: same namespace
module "rds_copy" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  vpc_name = var.vpc_name

  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"

  db_engine         = "postgres"
  db_engine_version = "17.6"
  rds_family        = "postgres17"
  db_instance_class = "db.t4g.micro"
  rds_name          = "folarin-dev-copy"
  snapshot_identifier = "folarin-dev-copy-20260325-1616"

  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

# Cross-namespace restore from namespace-demo-dan1
module "rds_dan" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  vpc_name = var.vpc_name

  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"

  db_engine         = "postgres"
  db_engine_version = "15" 
  rds_family        = "postgres15"
  db_instance_class = "db.t4g.micro"
  rds_name          = "rds-restore-dan"
  snapshot_identifier = "rds:cloud-platform-47d4c6e80a73418c-2026-03-20-05-01"

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
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

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
  db_engine_version = "17.6" # If you are managing minor version updates, refer to user guide: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/deploying-an-app/relational-databases/upgrade.html#upgrading-a-database-version-or-changing-the-instance-type
  rds_family        = "postgres17"
  db_instance_class = "db.t4g.micro"
  # It is mandatory to set the below values to create read replica instance

  # Set the db_identifier of the source db
  replicate_source_db = module.rds.db_identifier

  # Set to true. No backups or snapshots are created for read replica
  skip_final_snapshot        = "true"
  db_backup_retention_period = 0

  # If db_parameter is specified in source rds instance, use the same values.
  # If not specified you dont need to add any. It will use the default values.

  # db_parameter = [
  #   {
  #     name         = "rds.force_ssl"
  #     value        = "0"
  #     apply_method = "immediate"
  #   }
  # ]

  # If you want to assign AWS permissions to a k8s pod in your namespace - ie service pod for CLI queries,
  # uncomment below:

  # enable_irsa = true

  # If you want to enable Cloudwatch logging for this postgres RDS instance, uncomment the code below:
  # opt_in_xsiam_logging = true
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
  /* You can replace all of the above with the following, if you prefer to
     * use a single database URL value in your application code:
     *
     * url = "postgres://${module.rds.database_username}:${module.rds.database_password}@${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
     *
     */
}


resource "kubernetes_secret" "rds_copy" {
  metadata {
    name      = "rds-postgresql-copy-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_copy.rds_instance_endpoint
    database_name         = module.rds_copy.database_name
    database_username     = module.rds_copy.database_username
    database_password     = module.rds_copy.database_password
    rds_instance_address  = module.rds_copy.rds_instance_address
  }
}

resource "kubernetes_secret" "rds_dan" {
  metadata {
    name      = "rds-postgresql-dan-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_dan.rds_instance_endpoint
    database_name         = module.rds_dan.database_name
    database_username     = module.rds_dan.database_username
    database_password     = module.rds_dan.database_password
    rds_instance_address  = module.rds_dan.rds_instance_address
  }
}



resource "kubernetes_secret" "read_replica" {
  # default off
  count = 0

  metadata {
    name      = "rds-postgresql-read-replica-output"
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
    name      = "rds-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds.database_name
    db_identifier = module.rds.db_identifier
  }
}


resource "kubernetes_config_map" "rds_dan" {
  metadata {
    name      = "rds-postgresql-dan-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds_dan.database_name
    db_identifier = module.rds_dan.db_identifier
  }
}
