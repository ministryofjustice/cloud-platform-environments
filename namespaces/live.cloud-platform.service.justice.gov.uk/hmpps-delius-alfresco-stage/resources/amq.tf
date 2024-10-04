data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "this" {
  filter {
    name   = "tag:SubnetType"
    values = ["Private"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
}

data "aws_subnet" "this" {
  for_each = toset(data.aws_subnets.this.ids)
  id       = each.value
}

data "aws_subnets" "eks_private" {
  filter {
    name   = "tag:SubnetType"
    values = ["EKS-Private"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
}

data "aws_subnet" "eks_private" {
  for_each = toset(data.aws_subnets.eks_private.ids)
  id       = each.value
}

resource "random_id" "amq_id" {
  byte_length = 8
}

resource "random_string" "amq_username" {
  length  = 8
  special = false
}

resource "random_string" "amq_password" {
  length  = 16
  special = false
}

resource "random_id" "config_id" {
  byte_length = 8
}

locals {
  identifier         = "cloud-platform-${random_id.amq_id.hex}"
  mq_admin_user      = "cp${random_string.amq_username.result}"
  mq_admin_password  = random_string.amq_password.result
  subnets            = data.aws_subnets.this.ids
  amq_engine_version = "5.18"
  amq_engine_type    = "ActiveMQ"
  broker_count       = 3

  broker_zero = "${local.identifier}-0"
  broker_one  = "${local.identifier}-1"
  broker_two  = "${local.identifier}-2"

  network_conector_string = {
    0 = <<EOF
      <networkConnectors>
          <networkConnector name="connector_1_to_2" userName="${local.mq_admin_user}" duplex="true"
              uri="static:(${data.aws_mq_broker.by_name[local.broker_one].instances[0].endpoints[0]})"/>
          <networkConnector name="connector_1_to_3" userName="${local.mq_admin_user}" duplex="true"
              uri="static:(${data.aws_mq_broker.by_name[local.broker_two].instances[0].endpoints[0]})"/>
      </networkConnectors>
      EOF
    1 = <<EOF
      <networkConnectors>
          <networkConnector name="connector_2_to_3" userName="${local.mq_admin_user}" duplex="true"
              uri="static:(${data.aws_mq_broker.by_name[local.broker_two].instances[0].endpoints[0]})"/>
      </networkConnectors>
      EOF

    2 = ""
  }
}

data "aws_mq_broker" "by_name" {
  for_each    = toset([for i in range(local.broker_count) : "${local.identifier}-${i}"])
  broker_name = each.key
}

resource "aws_security_group" "broker_sg" {
  name        = local.identifier
  description = "Allow all inbound traffic"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = concat(
      [for s in data.aws_subnet.this : s.cidr_block],
      [for s in data.aws_subnet.eks_private : s.cidr_block]
    )
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = concat(
      [for s in data.aws_subnet.this : s.cidr_block],
      [for s in data.aws_subnet.eks_private : s.cidr_block]
    )
  }
}

resource "aws_mq_broker" "this" {
  count = local.broker_count

  broker_name = "${local.identifier}-${count.index}"

  engine_type         = local.amq_engine_type
  engine_version      = local.amq_engine_version
  deployment_mode     = "SINGLE_INSTANCE"
  host_instance_type  = "mq.m5.large"
  publicly_accessible = false
  subnet_ids          = [local.subnets[0]]
  security_groups     = [aws_security_group.broker_sg.id]

  configuration {
    id       = aws_mq_configuration.this[count.index].id
    revision = aws_mq_configuration.this[count.index].latest_revision
  }

  auto_minor_version_upgrade = true

  apply_immediately = false

  storage_type = "ebs"

  user {
    username       = local.mq_admin_user
    password       = local.mq_admin_password
    groups         = ["admin"]
    console_access = true
  }

  logs {
    general = true
    audit   = true
  }

  maintenance_window_start_time {
    day_of_week = "SUNDAY"
    time_of_day = "03:00"
    time_zone   = "UTC"
  }

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }

  lifecycle {
    ignore_changes = [ 
      configuration
      engine_version
     ]
  }
}

resource "aws_mq_configuration" "this" {
  count          = local.broker_count
  description    = "Alfresco Amazon MQ configuration"
  name           = "alfresco-amq-configuration-${random_id.config_id.hex}-${count.index}"
  engine_type    = local.amq_engine_type
  engine_version = local.amq_engine_version

  data = templatefile("${path.module}/files/amq_config.xml",
    {
      network_conector_string = local.network_conector_string[count.index]
    }
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes = [ data ]
  }
}

resource "kubernetes_secret" "amazon_mq" {
  metadata {
    name      = "amazon-mq-broker-secret"
    namespace = var.namespace
  }

  data = {
    BROKER_CONSOLE_URL_0 = aws_mq_broker.this[0].instances[0].console_url
    BROKER_CONSOLE_URL_1 = aws_mq_broker.this[1].instances[0].console_url
    BROKER_CONSOLE_URL_2 = aws_mq_broker.this[2].instances[0].console_url
    BROKER_URL           = "failover:(nio+${aws_mq_broker.this[0].instances[0].endpoints[0]},nio+${aws_mq_broker.this[1].instances[0].endpoints[0]},nio+${aws_mq_broker.this[2].instances[0].endpoints[0]})?initialReconnectDelay=1000&maxReconnectAttempts=-1&useExponentialBackOff=true&maxReconnectDelay=30000?reconnectSupported=true"
    BROKER_USERNAME      = local.mq_admin_user
    BROKER_PASSWORD      = local.mq_admin_password
  }
}

data "aws_iam_policy_document" "amq" {
  statement {
    actions = [
      "mq:CreateConfiguration",
      "mq:CreateUser",
      "mq:DeleteUser",
      "mq:DescribeBroker",
      "mq:DescribeBrokerEngineTypes",
      "mq:DescribeBrokerInstanceOptions",
      "mq:DescribeConfiguration",
      "mq:DescribeConfigurationRevision",
      "mq:DescribeUser",
      "mq:ListBrokers",
      "mq:ListConfigurationRevisions",
      "mq:ListConfigurations",
      "mq:ListUsers",
      "mq:RebootBroker",
      "mq:UpdateBroker",
      "mq:UpdateConfiguration",
      "mq:UpdateUser"
    ]
    resources = concat([for broker in aws_mq_broker.this : broker.arn], [for config in aws_mq_configuration.this : config.arn])
    # resources = [for broker in aws_mq_broker.this : broker.arn]
  }
}

data "aws_cloudwatch_log_group" "mq_broker_logs_general" {
  count = local.broker_count
  name  = "/aws/amazonmq/broker/${aws_mq_broker.this[count.index].id}/general"
}

data "aws_cloudwatch_log_group" "mq_broker_logs_audit" {
  count = local.broker_count
  name  = "/aws/amazonmq/broker/${aws_mq_broker.this[count.index].id}/audit"
}

data "aws_iam_policy_document" "amq_cw_logs" {
  statement {
    actions = [
      "logs:Describe*",
      "logs:Get*",
      "logs:List*",
      "logs:*Query*",
      "logs:*LiveTail*",
      "logs:TestMetricFilter",
      "logs:FilterLogEvents",
    ]
    resources = [for log_group in concat(data.aws_cloudwatch_log_group.mq_broker_logs_general, data.aws_cloudwatch_log_group.mq_broker_logs_audit) : log_group.arn]
  }
}

resource "aws_iam_policy" "amq" {
  name        = "cloud-platform-mq-${random_id.amq_id.hex}"
  description = "IAM policy for Amazon MQ"
  policy      = data.aws_iam_policy_document.amq.json
}
