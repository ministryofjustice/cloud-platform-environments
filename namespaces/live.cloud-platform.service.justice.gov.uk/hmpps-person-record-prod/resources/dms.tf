module "hmpps-person-record-dms" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dms?ref=3.0.0"

  vpc_name               = var.vpc_name
  namespace              = var.namespace
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  team_name              = var.team_name
}

resource "random_id" "dms_rand" {
  byte_length = 8
}

resource "aws_dms_endpoint" "source-ccs-prod-db" {
  endpoint_id                 = "${var.team_name}-src-ccs-prod-${random_id.dms_rand.hex}"
  endpoint_type               = "source"
  engine_name                 = "postgres"
  extra_connection_attributes = ""
  server_name                 = data.court-probation-prod-rds-instance-endpoint
  database_name               = data.court-probation-prod-rds-database-name
  username                    = data.court-probation-prod-rds-database-username
  password                    = data.court-probation-prod-rds-database-password
  port                        = 5432
  ssl_mode                    = "none"

  tags = {
    Name        = "${var.team_name} Source Endpoint"
    Description = "Current Prod Court Case Service Live database"
    Application = var.application
    Owner       = var.team_name
    Env         = var.environment
  }
}

resource "aws_dms_endpoint" "target-cpr-prod-db" {
  endpoint_id                 = "${var.team_name}-target-cpr-prod-${random_id.dms_rand.hex}"
  endpoint_type               = "target"
  engine_name                 = "postgres"
  extra_connection_attributes = ""
  server_name                 = module.hmpps_person_record_rds.rds_instance_address
  database_name               = module.hmpps_person_record_rds.database_name
  username                    = module.hmpps_person_record_rds.database_username
  password                    = module.hmpps_person_record_rds.database_password
  port                        = module.hmpps_person_record_rds.rds_instance_port
  ssl_mode                    = "none"

  tags = {
    Name        = "${var.team_name} Target Endpoint"
    Description = "Current Prod Person Record Live database"
    Application = var.application
    Owner       = var.team_name
    Env         = var.environment
  }
}

resource "aws_dms_replication_task" "ccs_to_cpr_replication_task" {
  migration_type           = "full-load"
  replication_instance_arn = module.hmpps-person-record-dms.replication_instance_arn
  replication_task_id      = "${var.team_name}-ccs-to-cpr-replication-instance-${random_id.dms_rand.hex}"

  source_endpoint_arn = aws_dms_endpoint.source-ccs-prod-db.endpoint_arn
  target_endpoint_arn = aws_dms_endpoint.target-cpr-prod-db.endpoint_arn

  table_mappings            = trimspace(file("settings/dms-table-mapping.json"))
  replication_task_settings = trimspace(file("settings/dms-replication-task-settings.json"))

  # bug https://github.com/hashicorp/terraform-provider-aws/issues/1513
  lifecycle { ignore_changes = ["replication_task_settings"] }

  tags = {
    Name        = "${var.team_name} Replication Task"
    Description = "Managed by Terraform"
    Application = var.application
    Owner       = var.team_name
    Env         = var.environment
  }
}

resource "kubernetes_secret" "ccs_to_cpr_replication_instance" {
  metadata {
    name      = "ccs-to-cpr-replication-instance"
    namespace = var.namespace
  }

  data = {
    replication_instance_arn = module.hmpps-person-record-dms.replication_instance_arn
    source                   = aws_dms_endpoint.source-ccs-prod-db.endpoint_arn
    destination              = aws_dms_endpoint.target-cpr-prod-db.endpoint_arn
    task                     = aws_dms_replication_task.ccs_to_cpr_replication_task.replication_task_arn
  }
}
