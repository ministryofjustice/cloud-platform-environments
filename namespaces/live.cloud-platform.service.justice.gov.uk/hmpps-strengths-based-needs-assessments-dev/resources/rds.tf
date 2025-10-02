module "hmpps_strengths_based_needs_assessments_dev_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
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

  vpc_security_group_ids = [module.rds_security_group.security_group_id]
}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

module "rds_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.2.0"

  name = "sbna_modernisation_platform_access"

  vpc_id = data.aws_vpc.this.id

  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = "10.26.8.0/21"
    },

  ]
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

data "aws_ssm_parameter" "integrations_rds_database_name" {
  name = "/hmpps-assess-risks-and-needs-integrations-dev/rds-database-name"
}

data "aws_ssm_parameter" "integrations_rds_database_username" {
  name = "/hmpps-assess-risks-and-needs-integrations-dev/rds-database-username"
}

data "aws_ssm_parameter" "integrations_rds_database_password" {
  name = "/hmpps-assess-risks-and-needs-integrations-dev/rds-database-password"
}

data "aws_ssm_parameter" "integrations_rds_instance_address" {
  name = "/hmpps-assess-risks-and-needs-integrations-dev/rds-instance-address"
}

data "aws_ssm_parameter" "integrations_rds_instance_port" {
  name = "/hmpps-assess-risks-and-needs-integrations-dev/rds-instance-port"
}

# Installs postgres_fdw extension
resource "postgresql_extension" "postgres_fdw" {
  name = "postgres_fdw"
}

# Create Foreign Server
resource "postgresql_server" "integrations_rds" {
  server_name = "integrations_rds"
  fdw_name    = "postgres_fdw"
  options = {
    host   = data.aws_ssm_parameter.integrations_rds_instance_address.value # Other server
    port   = data.aws_ssm_parameter.integrations_rds_instance_port.value # Other port
    dbname = data.aws_ssm_parameter.integrations_rds_database_name.value # Other DB name
  }

  depends_on = [postgresql_extension.postgres_fdw]
}

resource "postgresql_user_mapping" "remote_mapping" {
  server_name = postgresql_server.integrations_rds.server_name
  user_name   = module.hmpps_strengths_based_needs_assessments_dev_rds.database_username
  options = {
    user = data.aws_ssm_parameter.integrations_rds_database_username.value # username for other server
    password = data.aws_ssm_parameter.integrations_rds_database_password.value # password for other server
  }
}
