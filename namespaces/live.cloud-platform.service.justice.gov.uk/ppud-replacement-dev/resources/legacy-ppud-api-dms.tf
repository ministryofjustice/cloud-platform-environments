data "kubernetes_secret" "ppud_cdc_database" {
  metadata {
    name      = "ppud-cdc-database"
    namespace = var.namespace
  }
}

resource "kubernetes_secret" "dms_secret" {
  metadata {
    name      = "dms-secret"
    namespace = var.namespace
  }

  data = {
    src_addr     = data.kubernetes_secret.ppud_cdc_database.data.host
    src_port     = data.kubernetes_secret.ppud_cdc_database.data.port
    src_ssl      = "none"
    src_engine   = "sqlserver"
    src_user     = data.kubernetes_secret.ppud_cdc_database.data.username
    src_pass     = data.kubernetes_secret.ppud_cdc_database.data.password
    src_database = "PPUD_CDC_REPL"
    dst_addr     = module.ppud_replica_dev_rds.rds_instance_address
    dst_port     = module.ppud_replica_dev_rds.rds_instance_port
    dst_ssl      = "none"
    dst_engine   = "sqlserver"
    dst_user     = module.ppud_replica_dev_rds.database_username
    dst_pass     = module.ppud_replica_dev_rds.database_password
    dst_database = "PPUD_CDC_REPL"
  }
}

module "ppud_dms" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dms?ref=2.4.1"

  vpc_name               = var.vpc_name
  namespace              = var.namespace
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  team_name              = var.team_name
}

data "kubernetes_secret" "dms_secret" {
  metadata {
    name      = "dms-secret"
    namespace = var.namespace
  }

  depends_on = [
    kubernetes_secret.dms_secret
  ]
}

resource "random_id" "id" {
  byte_length = 8
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_endpoint

resource "aws_dms_endpoint" "source" {
  endpoint_id                 = "${var.team_name}-src-${random_id.id.hex}"
  endpoint_type               = "source"
  engine_name                 = data.kubernetes_secret.dms_secret.data.src_engine
  extra_connection_attributes = ""
  server_name                 = data.kubernetes_secret.dms_secret.data.src_addr
  database_name               = data.kubernetes_secret.dms_secret.data.src_database
  username                    = data.kubernetes_secret.dms_secret.data.src_user
  password                    = data.kubernetes_secret.dms_secret.data.src_pass
  port                        = data.kubernetes_secret.dms_secret.data.src_port
  ssl_mode                    = data.kubernetes_secret.dms_secret.data.src_ssl

  tags = {
    Name        = "${var.team_name} Source Endpoint"
    Description = "Managed by Terraform"
    Application = var.application
    Owner       = var.team_name
    Env         = var.environment
  }
}

resource "aws_dms_endpoint" "target" {
  endpoint_id                 = "${var.team_name}-dst-${random_id.id.hex}"
  endpoint_type               = "target"
  engine_name                 = data.kubernetes_secret.dms_secret.data.dst_engine
  extra_connection_attributes = ""
  server_name                 = data.kubernetes_secret.dms_secret.data.dst_addr
  database_name               = data.kubernetes_secret.dms_secret.data.dst_database
  username                    = data.kubernetes_secret.dms_secret.data.dst_user
  password                    = data.kubernetes_secret.dms_secret.data.dst_pass
  port                        = data.kubernetes_secret.dms_secret.data.dst_port
  ssl_mode                    = data.kubernetes_secret.dms_secret.data.dst_ssl

  tags = {
    Name        = "${var.team_name} Destination Endpoint"
    Description = "Managed by Terraform"
    Application = var.application
    Owner       = var.team_name
    Env         = var.environment
  }
}

locals {
  replication_task_id = "${var.team_name}-repl-${random_id.id.hex}"
}

resource "aws_dms_replication_task" "replication_task" {
  # two values make sense here: full-load or full-load-and-cdc; see https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Task.CDC.html for details
  # most notably, Azure SQL does not support CDC
  migration_type           = "full-load-and-cdc"
  replication_instance_arn = module.ppud_dms.replication_instance_arn
  replication_task_id      = local.replication_task_id

  source_endpoint_arn = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn = aws_dms_endpoint.target.endpoint_arn

  table_mappings            = "{\"rules\":[{\"rule-type\":\"selection\",\"rule-id\":\"1\",\"rule-name\":\"1\",\"object-locator\":{\"schema-name\":\"%\",\"table-name\":\"%\"},\"rule-action\":\"include\"}]}"
  replication_task_settings = ""

  # bug https://github.com/hashicorp/terraform-provider-aws/issues/1513
  lifecycle {
    ignore_changes = [replication_task_settings]
  }

  tags = {
    Name        = "${var.team_name} Replication Task"
    Description = "Managed by Terraform"
    Application = var.application
    Owner       = var.team_name
    Env         = var.environment
  }
}

resource "kubernetes_secret" "dms_instance" {
  metadata {
    name      = "dms-instance"
    namespace = var.namespace
  }

  data = {
    replication_instance_arn = module.ppud_dms.replication_instance_arn
    access_key_id            = module.ppud_dms.access_key_id
    secret_access_key        = module.ppud_dms.secret_access_key
    source                   = aws_dms_endpoint.source.endpoint_arn
    destination              = aws_dms_endpoint.target.endpoint_arn
    replication_task_arn     = aws_dms_replication_task.replication_task.replication_task_arn
    replication_task_id      = local.replication_task_id
  }
}
