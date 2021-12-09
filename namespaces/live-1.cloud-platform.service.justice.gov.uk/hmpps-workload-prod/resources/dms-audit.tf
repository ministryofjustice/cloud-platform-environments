module "hmpps-workload-audit-dms" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dms?ref=2.0"

  cluster_name           = var.cluster_name
  namespace              = var.namespace
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  team_name              = var.team_name
}

resource "random_id" "dms_audit_rand" {
  byte_length = 8
}

resource "aws_dms_endpoint" "source-live" {
  endpoint_id                 = "${var.team_name}-srclive-${random_id.dms_audit_rand.hex}"
  endpoint_type               = "source"
  engine_name                 = "postgres"
  extra_connection_attributes = ""
  server_name                 = module.rds-live.rds_instance_address
  database_name               = module.rds-live.database_name
  username                    = module.rds-live.database_username
  password                    = module.rds-live.database_password
  port                        = module.rds-live.rds_instance_port
  ssl_mode                    = "require"

  tags = {
    Name        = "${var.team_name} Source Endpoint"
    Description = "WMT Live database"
    Application = var.application
    Owner       = var.team_name
    Env         = var.environment
  }
}

resource "aws_dms_endpoint" "target-history" {
  endpoint_id                 = "${var.team_name}-historypostgres-${random_id.dms_audit_rand.hex}"
  endpoint_type               = "target"
  engine_name                 = "postgres"
  extra_connection_attributes = ""
  server_name                 = module.rds-history.rds_instance_address
  database_name               = module.rds-history.database_name
  username                    = module.rds-history.database_username
  password                    = module.rds-history.database_password
  port                        = module.rds-history.rds_instance_port
  ssl_mode                    = "require"

  tags = {
    Name        = "${var.team_name} Destination Endpoint"
    Description = "WMT History Database"
    Application = var.application
    Owner       = var.team_name
    Env         = var.environment
  }
}

resource "aws_dms_replication_task" "replication_audit_task" {
  migration_type           = "full-load"
  replication_instance_arn = module.hmpps-workload-audit-dms.replication_instance_arn
  replication_task_id      = "${var.team_name}-auditrepl-${random_id.dms_audit_rand.hex}"

  source_endpoint_arn = aws_dms_endpoint.source-live.endpoint_arn
  target_endpoint_arn = aws_dms_endpoint.target-history.endpoint_arn

  table_mappings            = trimspace(file("settings/dms-table-mappings-audit.json"))
  replication_task_settings = ""

  tags = {
    Name        = "${var.team_name} Replication Task"
    Description = "Managed by Terraform"
    Application = var.application
    Owner       = var.team_name
    Env         = var.environment
  }

  # bug https://github.com/hashicorp/terraform-provider-aws/issues/1513
  lifecycle { ignore_changes = ["replication_task_settings"] }
}

resource "kubernetes_secret" "dms_audit_instance" {
  metadata {
    name      = "dms-audit-instance"
    namespace = var.namespace
  }

  data = {
    replication_instance_arn = module.hmpps-workload-audit-dms.replication_instance_arn
    access_key_id            = module.hmpps-workload-audit-dms.access_key_id
    secret_access_key        = module.hmpps-workload-audit-dms.secret_access_key
    source                   = aws_dms_endpoint.source-live.endpoint_arn
    destination              = aws_dms_endpoint.target-history.endpoint_arn
    task                     = aws_dms_replication_task.replication_audit_task.replication_task_arn
  }
}
