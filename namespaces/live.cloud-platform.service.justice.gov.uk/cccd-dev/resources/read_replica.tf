module "read_replica" {
  # default off as in count = 0
  count  = 1
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.0"

  vpc_name               = var.vpc_name
  application            = var.application
  environment_name       = var.environment-name
  is_production          = var.is_production
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  business_unit          = var.business_unit
  namespace              = var.namespace

  # If any other inputs of the RDS is passed in the source db which are different from defaults,
  # add them to the replica

  # PostgreSQL specifics
  db_engine                   = "postgres"
  db_engine_version           = "13"
  rds_family                  = "postgres13"
  db_instance_class           = "db.t4g.micro"
  db_allocated_storage        = "80"
  db_max_allocated_storage    = "550"
  allow_major_version_upgrade = "true"
  db_parameter                = [{ name = "rds.force_ssl", value = "0", apply_method = "immediate" }]
  # It is mandatory to set the below values to create read replica instance

  # Set the database_name of the source db
  db_name = null # "db_name": conflicts with replicate_source_db

  # Set the db_identifier of the source db
  # replicate_source_db = module.rds.db_identifier
  replicate_source_db = module.cccd_rds.db_identifier

  # Set to true. No backups or snapshots are created for read replica
  skip_final_snapshot        = "true"
  db_backup_retention_period = 0
}

resource "kubernetes_secret" "read_replica" {
  count = 1

  metadata {
    name      = "rds-postgresql-read-replica-output"
    namespace = var.namespace
  }

  # The database_username, database_password, database_name values are same as the source RDS instance.
  # Uncomment if count > 0 as in on. if count < 0 then it's off
  data = {
    rds_instance_endpoint = module.read_replica[0].rds_instance_endpoint
    # rds_instance_address  = module.read_replica.rds_instance_address
    # access_key_id         = module.read_replica.access_key_id
    # secret_access_key     = module.read_replica.secret_access_key
  }
}