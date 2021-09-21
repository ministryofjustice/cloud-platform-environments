module "raz_test_dms" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dms?ref=new-use"

  cluster_name           = var.cluster_name
  namespace              = var.namespace
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  team_name              = var.team_name
}

resource "kubernetes_secret" "dms_instance" {
  metadata {
    name      = "dms-instance"
    namespace = var.namespace
  }

  data = {
    replication_instance_arn = module.raz_test_dms.replication_instance_arn
    access_key_id            = module.raz_test_dms.access_key_id
    secret_access_key        = module.raz_test_dms.secret_access_key
  }
}

data "kubernetes_secret" "dms_secret" {
  metadata {
    name = "dms-secret"
    namespace = var.namespace
  }
}

resource "random_id" "id" {
  byte_length = 8
}

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
  ssl_mode                    = data.kubernetes_secret.dms_secret.data.src_tls

  tags = {
    Name        = "${var.team_name} Source Endpoint"
    Description = "Managed by Terraform"
    Application = "${var.application}"
    Owner       = "${var.team_name}"
    Env         = "${var.environment-name}"
  }
}

resource "aws_dms_endpoint" "destination" {
  endpoint_id                 = "${var.team_name}-dst-${random_id.id.hex}"
  endpoint_type               = "destination"
  engine_name                 = data.kubernetes_secret.dms_secret.data.dst_engine
  extra_connection_attributes = ""
  server_name                 = data.kubernetes_secret.dms_secret.data.dst_addr
  database_name               = data.kubernetes_secret.dms_secret.data.dst_database
  username                    = data.kubernetes_secret.dms_secret.data.dst_user
  password                    = data.kubernetes_secret.dms_secret.data.dst_pass
  port                        = data.kubernetes_secret.dms_secret.data.dst_port
  ssl_mode                    = data.kubernetes_secret.dms_secret.data.dst_tls

  tags = {
    Name        = "${var.team_name} Source Endpoint"
    Description = "Managed by Terraform"
    Application = "${var.application}"
    Owner       = "${var.team_name}"
    Env         = "${var.environment-name}"
  }
}
