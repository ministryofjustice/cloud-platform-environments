resource "random_string" "username" {
  length  = 8
  special = false
}

resource "random_string" "password" {
  length  = 24
  special = false
}

locals {
  username = random_string.username.result
  password = random_string.password.result
}

resource "aws_mq_broker" "rabbit" {
  broker_name        = "rabbit"
  engine_type        = "RabbitMQ"
  engine_version     = "3.13"
  host_instance_type = "mq.m5.large"
  
  auto_minor_version_upgrade = true

  user {
    username = local.username
    password = local.password
  }

  configuration {
    id       = aws_mq_configuration.rabbit.id
    revision = aws_mq_configuration.rabbit.latest_revision
  }
  
}

resource "aws_mq_configuration" "rabbit" {
  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    namespace              = var.namespace
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
    GithubTeam             = var.team_name
  }
}

data "aws_iam_policy_document" "amq" {
  statement {
    actions = ["mq:*"]
    resources = [aws_mq_broker.rabbit.arn]
  }
}

resource "aws_iam_policy" "amq" {
  name        = "${var.namespace}-amazonmq-policy"
  description = "IAM policy for Amazon MQ"
  policy      = data.aws_iam_policy_document.amq.json
}

resource "kubernetes_secret" "amq" {
  metadata {
    name      = "amq-output"
    namespace = var.namespace
  }

  data = {
    amq_id          = aws_mq_broker.rabbit.id
    amq_arn         = aws_mq_broker.rabbit.arn
    amq_console_url = aws_mq_broker.rabbit.instances[0].console_url
    amq_endpoint    = aws_mq_broker.rabbit.instances[0].endpoints[0]
    amq_username    = local.username
    amq_password    = local.password
  }
}
