module "hmpps-workload-impact-testing-dms" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dms?ref=2.4.2"

  vpc_name               = var.vpc_name
  namespace              = var.namespace
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  team_name              = var.team_name
}

resource "random_id" "dms_rand" {
  byte_length = 8
}


data "kubernetes_secret" "dms_impact_testing_secret" {
  metadata {
    name      = "dms-impact-testing-secret"
    namespace = var.namespace
  }
}

resource "aws_dms_endpoint" "source-prod-db" {
  endpoint_id                 = "${var.team_name}-src-wmt-prod-${random_id.dms_rand.hex}"
  endpoint_type               = "source"
  engine_name                 = data.kubernetes_secret.dms_impact_testing_secret.data.src_engine
  extra_connection_attributes = ""
  server_name                 = data.kubernetes_secret.dms_impact_testing_secret.data.src_addr
  database_name               = data.kubernetes_secret.dms_impact_testing_secret.data.src_database
  username                    = data.kubernetes_secret.dms_impact_testing_secret.data.src_user
  password                    = data.kubernetes_secret.dms_impact_testing_secret.data.src_pass
  port                        = data.kubernetes_secret.dms_impact_testing_secret.data.src_port
  ssl_mode                    = data.kubernetes_secret.dms_impact_testing_secret.data.src_ssl

  tags = {
    Name        = "${var.team_name} Source Endpoint"
    Description = "Current Prod WMT Live database"
    Application = var.application
    Owner       = var.team_name
    Env         = var.environment
  }
}

resource "aws_dms_endpoint" "target-preprod-db" {
  endpoint_id                 = "${var.team_name}-target-wmt-preprod-${random_id.dms_rand.hex}"
  endpoint_type               = "target"
  engine_name                 = data.kubernetes_secret.dms_impact_testing_secret.data.src_engine
  extra_connection_attributes = ""
  server_name                 = module.rds-live.rds_instance_address
  database_name               = module.rds-live.database_name
  username                    = module.rds-live.database_username
  password                    = module.rds-live.database_password
  port                        = module.rds-live.rds_instance_port
  ssl_mode                    = data.kubernetes_secret.dms_impact_testing_secret.data.src_ssl

  tags = {
    Name        = "${var.team_name} Source Endpoint"
    Description = "Current Prod WMT Live database"
    Application = var.application
    Owner       = var.team_name
    Env         = var.environment
  }
}

resource "aws_dms_replication_task" "replication_impact_testing_full_task" {
  migration_type           = "full-load"
  replication_instance_arn = module.hmpps-workload-impact-testing-dms.replication_instance_arn
  replication_task_id      = "${var.team_name}-repl-impact-full-${random_id.dms_rand.hex}"

  source_endpoint_arn = aws_dms_endpoint.source-prod-db.endpoint_arn
  target_endpoint_arn = aws_dms_endpoint.target-preprod-db.endpoint_arn

  table_mappings            = trimspace(file("settings/dms-table-mappings-full.json"))
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

resource "kubernetes_secret" "dms_impact_testing_instance" {
  metadata {
    name      = "dms-impact-testing-instance"
    namespace = var.namespace
  }

  data = {
    replication_instance_arn = module.hmpps-workload-impact-testing-dms.replication_instance_arn
    access_key_id            = module.hmpps-workload-impact-testing-dms.access_key_id
    secret_access_key        = module.hmpps-workload-impact-testing-dms.secret_access_key
    source                   = aws_dms_endpoint.source-prod-db.endpoint_arn
    destination              = aws_dms_endpoint.target-preprod-db.endpoint_arn
    full_task                = aws_dms_replication_task.replication_impact_testing_full_task.replication_task_arn
  }
}
