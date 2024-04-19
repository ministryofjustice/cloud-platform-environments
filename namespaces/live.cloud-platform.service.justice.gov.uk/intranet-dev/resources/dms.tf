module "test_dms" {
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

data "kubernetes_secret" "dms_secret" {
  metadata {
    name      = "dms-secret"
    namespace = var.namespace
  }
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

resource "kubernetes_secret" "dms_instance" {
  metadata {
    name      = "dms-instance"
    namespace = var.namespace
  }

  data = {
    replication_instance_arn = module.test_dms.replication_instance_arn
    source                   = aws_dms_endpoint.source.endpoint_arn
    destination              = aws_dms_endpoint.target.endpoint_arn
    task                     = aws_dms_replication_task.replication_task.replication_task_arn
  }
}