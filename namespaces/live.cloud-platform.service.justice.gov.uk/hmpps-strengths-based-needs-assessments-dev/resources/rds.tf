module "hmpps_strengths_based_needs_assessments_dev_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.0.1"
  db_allocated_storage   = 10
  storage_type           = "gp2"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  rds_family             = "postgres16"
  db_instance_class      = "db.t4g.small"
  db_engine              = "postgres"
  db_engine_version      = "16"

  allow_major_version_upgrade = "true"
  prepare_for_major_upgrade   = false

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_strengths_based_needs_assessments_dev_rds_secret" {
  metadata {
    name      = "hmpps-strengths-based-needs-assessments-rds-instance"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps_strengths_based_needs_assessments_dev_rds.rds_instance_endpoint
    database_name         = module.hmpps_strengths_based_needs_assessments_dev_rds.database_name
    database_username     = module.hmpps_strengths_based_needs_assessments_dev_rds.database_username
    database_password     = module.hmpps_strengths_based_needs_assessments_dev_rds.database_password
    rds_instance_address  = module.hmpps_strengths_based_needs_assessments_dev_rds.rds_instance_address
    url                   = "postgres://${module.hmpps_strengths_based_needs_assessments_dev_rds.database_username}:${module.hmpps_strengths_based_needs_assessments_dev_rds.database_password}@${module.hmpps_strengths_based_needs_assessments_dev_rds.rds_instance_endpoint}/${module.hmpps_strengths_based_needs_assessments_dev_rds.database_name}"
  }
}

provider "postgresql" {
  database         = module.hmpps_strengths_based_needs_assessments_dev_rds.database_name
  host             = module.hmpps_strengths_based_needs_assessments_dev_rds.rds_instance_address
  port             = module.hmpps_strengths_based_needs_assessments_dev_rds.rds_instance_port
  username         = module.hmpps_strengths_based_needs_assessments_dev_rds.database_username
  password         = module.hmpps_strengths_based_needs_assessments_dev_rds.database_password
  expected_version = "16"
  sslmode          = "require"
  superuser        = false
}

# Installs postgres dblink extension
resource "postgresql_extension" "dblink_new" {
  name = "dblink"
}

# Installs postgres_fdw extension
resource "postgresql_extension" "postgres_fdw" {
  name = "postgres_fdw"
}

# Create Foreign Server
resource "postgresql_server" "myserver_postgres" {
  server_name = "myserver_postgres"
  fdw_name    = "postgres_fdw"
  options = {
    host   = data.coordinator_state.hmpps_assess_risks_and_needs_integrations_dev_rds.outputs.rds_instance_address # Other server
    dbname = data.coordinator_state.hmpps_assess_risks_and_needs_integrations_dev_rds.outputs.database_name # Other DB name
    port   = data.coordinator_state.hmpps_assess_risks_and_needs_integrations_dev_rds.outputs.rds_instance_port # Other port
  }

  depends_on = [postgresql_extension.postgres_fdw]
}

# Create User Mapping
resource "postgresql_role" "remote_role" {
  name = "remote"
}

resource "postgresql_user_mapping" "remote_mapping" {
  server_name = postgresql_server.myserver_postgres.server_name
  user_name   = postgresql_role.remote_role.name
  options = {
    user = data.coordinator_state.hmpps_assess_risks_and_needs_integrations_dev_rds.outputs.database_username # username for other server
    password = data.coordinator_state.hmpps_assess_risks_and_needs_integrations_dev_rds.outputs.database_password # for other server
  }
}

# Import Tables
data "postgresql_tables" "tables" {
  database = data.coordinator_state.hmpps_assess_risks_and_needs_integrations_dev_rds.outputs.database_name
}
