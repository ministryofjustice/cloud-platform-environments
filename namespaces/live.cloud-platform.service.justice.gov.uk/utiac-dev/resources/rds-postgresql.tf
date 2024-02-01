module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  # enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "14.7"
  rds_family        = "postgres14"
  db_instance_class = "db.t4g.micro"

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  vpc_security_group_ids = [aws_security_group.rds.id]
}

# Get VPC id
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

# Additional RDS SG
resource "aws_security_group" "rds" {
  name        = "${var.namespace}-RDS-${var.environment}"
  description = "RDS VPC Security Group for Ingress Traffic"
  vpc_id      = data.aws_vpc.selected.id

  lifecycle {
    create_before_destroy = true
  }
}

# Allow MoJ vpn connections
resource "aws_security_group_rule" "rule" {
  cidr_blocks       = ["81.134.202.29/32"]
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 5432
  to_port           = 5432
  security_group_id = aws_security_group.rds.id
}

# To create a read replica, use the below code and update the values to specify the RDS instance
# from which you are replicating. In this example, we're assuming that rds is the
# source RDS instance and read-replica is the replica we are creating.

module "read_replica" {
  # default off
  count  = 0
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"

  vpc_name               = var.vpc_name
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  is_production          = var.is_production
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
  team_name              = var.team_name

  # If any other inputs of the RDS is passed in the source db which are different from defaults,
  # add them to the replica

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "14.7"
  rds_family        = "postgres14"
  db_instance_class = "db.t4g.micro"
  # It is mandatory to set the below values to create read replica instance

  # Set the database_name of the source db
  db_name = null # "db_name": conflicts with replicate_source_db

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
