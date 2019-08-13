module "dps_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.5"
  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "${var.team_name}"
  business-unit          = "${var.business-unit}"
  application            = "${var.application}"
  is-production          = "${var.is-production}"
  environment-name       = "${var.environment-name}"
  infrastructure-support = "${var.infrastructure-support}"
  force_ssl              = "true"

  providers = {
    aws = "aws.london"
  }
}

resource "random_id" "risk_profiler_role_password" {
  byte_length = 32
}

provider "postgresql" {
  host      = "${module.dps_rds.rds_instance_address}"
  port      = "${module.dps_rds.rds_instance_port}"
  database  = "${module.dps_rds.database_name}"
  username  = "${module.dps_rds.database_username}"
  password  = "${module.dps_rds.database_password}"
  superuser = false
}

resource "postgresql_database" "risk_profiler" {
  name              = "risk_profiler"
  allow_connections = true
}

resource "postgresql_role" "risk_profiler" {
  name     = "risk_profiler"
  login    = true
  password = "${random_id.risk_profiler_role_password.b64}"
}

resource postgresql_grant "risk_profiler_tables" {
  database    = "risk_profiler"
  role        = "risk_profiler"
  schema      = "public"
  object_type = "table"
  privileges  = ["SELECT", "UPDATE", "INSERT", "CREATE"]
}

resource "kubernetes_secret" "dps_rds" {
  metadata {
    name      = "dps-rds-instance-output"
    namespace = "${var.namespace}"
  }

  data {
    rds_instance_endpoint  = "${module.dps_rds.rds_instance_endpoint}"
    database_name          = "${module.dps_rds.database_name}"
    database_username      = "${module.dps_rds.database_username}"
    database_password      = "${module.dps_rds.database_password}"
    rds_instance_address   = "${module.dps_rds.rds_instance_address}"
    risk_profiler_name     = "${postgresql_database.risk_profiler.name}"
    risk_profiler_username = "${postgresql_role.risk_profiler.name}"
    risk_profiler_password = "${random_id.risk_profiler_role_password.b64}"
  }
}
