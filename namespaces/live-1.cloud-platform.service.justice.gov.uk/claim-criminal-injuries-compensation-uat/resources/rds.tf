variable "cluster_name" {}
variable "cluster_state_bucket" {}

module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.5"

  cluster_name               = "${var.cluster_name}"
  cluster_state_bucket       = "${var.cluster_state_bucket}"
  team_name                  = "${var.team_name}"
  business-unit              = "${var.business-unit}"
  application                = "${var.application}"
  is-production              = "${var.is-production}"
  environment-name           = "${var.environment-name}"
  infrastructure-support     = "${var.email}"
  force_ssl                  = "true"
  db_engine                  = "postgres"
  db_engine_version          = "10.6"
  db_instance_class          = "db.t2.small"
  db_allocated_storage       = "5"
  db_name                    = "datacaptureservice"
  db_backup_retention_period = "${var.db_backup_retention_period}"

  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11 
  # Pick the one that defines the postgres version the best 
  rds_family = "postgres10"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine 
  allow_major_version_upgrade = "true"

  providers = {
    # Can be either "aws.london" or "aws.ireland" 
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds"
    namespace = "${var.namespace}"
  }

  data {
    rds_instance_endpoint = "${module.rds.rds_instance_endpoint}"
    database_name         = "${module.rds.database_name}"
    database_username     = "${module.rds.database_username}"
    database_password     = "${module.rds.database_password}"
    rds_instance_address  = "${module.rds.rds_instance_address}"
    rds_instance_port     = "${module.rds.rds_instance_port}"
  }
}
