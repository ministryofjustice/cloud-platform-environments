# data "aws_caller_identity" "current" {}
# data "aws_region" "current" {}

# data "aws_vpc" "this" {
#   filter {
#     name   = "tag:Name"
#     values = [var.vpc_name]
#   }
# }

# data "aws_subnets" "this" {
#   filter {
#     name   = "tag:SubnetType"
#     values = ["Private"]
#   }

#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.this.id]
#   }
# }

# data "aws_subnet" "this" {
#   for_each = toset(data.aws_subnets.this.ids)
#   id       = each.value
# }

# data "aws_subnets" "eks_private" {
#   filter {
#     name   = "tag:SubnetType"
#     values = ["EKS-Private"]
#   }

#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.this.id]
#   }
# }

# data "aws_subnet" "eks_private" {
#   for_each = toset(data.aws_subnets.eks_private.ids)
#   id       = each.value
# }

# resource "random_id" "amq_id" {
#   byte_length = 8
# }

# resource "random_string" "amq_username" {
#   length  = 8
#   special = false
# }

# resource "random_string" "amq_password" {
#   length  = 16
#   special = false
# }

# locals {
#   identifier        = "cloud-platform-${random_id.amq_id.hex}"
#   mq_admin_user     = "cp${random_string.amq_username.result}"
#   mq_admin_password = random_string.amq_password.result
#   subnets           = data.aws_subnets.this.ids
# }

# resource "aws_security_group" "broker_sg" {
#   name        = local.identifier
#   description = "Allow all inbound traffic"
#   vpc_id      = data.aws_vpc.this.id

#   ingress {
#     from_port = 0
#     to_port   = 0
#     protocol  = "-1"
#     cidr_blocks = concat(
#       [for s in data.aws_subnet.this : s.cidr_block],
#       [for s in data.aws_subnet.eks_private : s.cidr_block]
#     )
#   }

#   egress {
#     from_port = 0
#     to_port   = 0
#     protocol  = "-1"
#     cidr_blocks = concat(
#       [for s in data.aws_subnet.this : s.cidr_block],
#       [for s in data.aws_subnet.eks_private : s.cidr_block]
#     )
#   }
# }

# resource "aws_mq_broker" "this" {
#   broker_name = local.identifier

#   engine_type         = "ActiveMQ"
#   engine_version      = "5.18"
#   deployment_mode     = "SINGLE_INSTANCE"
#   host_instance_type  = "mq.m5.large"
#   publicly_accessible = false
#   subnet_ids          = [local.subnets[0]]
#   security_groups     = [aws_security_group.broker_sg.id]

#   auto_minor_version_upgrade = true

#   storage_type = "ebs"

#   user {
#     username       = local.mq_admin_user
#     password       = local.mq_admin_password
#     groups         = ["admin"]
#     console_access = false
#   }


#   logs {
#     general = true
#     audit   = false
#   }

#   maintenance_window_start_time {
#     day_of_week = "SUNDAY"
#     time_of_day = "03:00"
#     time_zone   = "UTC"
#   }

#   tags = {
#     business-unit          = var.business_unit
#     application            = var.application
#     is-production          = var.is_production
#     environment-name       = var.environment_name
#     owner                  = var.team_name
#     infrastructure-support = var.infrastructure_support
#     namespace              = var.namespace
#   }
# }

# resource "kubernetes_secret" "amazon_mq" {
#   metadata {
#     name      = "amazon-mq-broker-secret"
#     namespace = var.namespace
#   }

#   data = {
#     BROKER_CONSOLE_URL = aws_mq_broker.this.instances[0].console_url
#     BROKER_URL         = aws_mq_broker.this.instances[0].endpoints[0]
#     BROKER_USERNAME    = local.mq_admin_user
#     BROKER_PASSWORD    = local.mq_admin_password
#   }
# }
