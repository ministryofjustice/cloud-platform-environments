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
  broker_name         = "rabbit"
  engine_type         = "RabbitMQ"
  engine_version      = "3.13"
  host_instance_type  = "mq.m5.large"
  publicly_accessible = false
  subnet_ids          = [local.subnets[0]]
  security_groups     = [aws_security_group.broker_sg.id]
  
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
