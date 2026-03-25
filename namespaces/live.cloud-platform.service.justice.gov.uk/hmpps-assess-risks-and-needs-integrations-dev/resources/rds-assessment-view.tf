module "arns_assessment_view_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  prepare_for_major_upgrade    = false
  performance_insights_enabled = false
  deletion_protection          = true
  db_max_allocated_storage     = "500"
  enable_rds_auto_start_stop   = true

  # PostgreSQL specifics
  db_allocated_storage = 20
  storage_type         = "gp3"
  rds_family           = "postgres18"
  db_engine            = "postgres"
  db_engine_version    = "18"
  db_instance_class    = "db.t4g.micro"

  # Tags
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  # Name
  rds_name = "hmpps-arns-assessment-view-db-${var.environment}"

  enable_irsa = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "arns_assessment_view_rds" {
  metadata {
    name      = "rds-arns-assessment-view-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.arns_assessment_view_rds.rds_instance_endpoint
    database_name         = module.arns_assessment_view_rds.database_name
    database_username     = module.arns_assessment_view_rds.database_username
    database_password     = module.arns_assessment_view_rds.database_password
    rds_instance_address  = module.arns_assessment_view_rds.rds_instance_address
    url                   = "postgres://${module.arns_assessment_view_rds.database_username}:${module.arns_assessment_view_rds.database_password}@${module.arns_assessment_view_rds.rds_instance_endpoint}/${module.arns_assessment_view_rds.database_name}"
  }
}

locals {
  secret_arn = "arn:aws:secretsmanager:eu-west-2:771283872747:secret:dev/dpr-crossaccount-test-secret-Vpq1q0"

  db_secret_raw = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)

  db_secret = {
    username = tostring(local.db_secret_raw.username)
    password = tostring(local.db_secret_raw.password)
    engine   = tostring(local.db_secret_raw.engine)
    host     = tostring(local.db_secret_raw.host)
    port     = tonumber(local.db_secret_raw.port)
    dbname   = tostring(local.db_secret_raw.dbname)
  }
}

data "aws_secretsmanager_secret_version" "db" {
  provider  = aws.secrets
  secret_id = local.secret_arn
}

resource "kubernetes_secret_v1" "db_credentials" {
  metadata {
    name      = "dpr-db-credentials"
    namespace = var.namespace
  }

  type = "Opaque"

  data = {
    username = local.db_secret.username
    password = local.db_secret.password
    engine   = local.db_secret.engine
    host     = local.db_secret.host
    port     = tostring(local.db_secret.port)
    dbname   = local.db_secret.dbname
  }
}
