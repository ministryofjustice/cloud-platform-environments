# Get VPC id
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name == "live" ? "live-1" : var.vpc_name]
  }
}

#Get reporting service's RDS security group
data "aws_security_group" "reporting_service_rds" {
  filter {
    name   = "group-name"
    values = ["laa-data-claims-reporting-service-prod-rds-sg"]
  }
  vpc_id = data.aws_vpc.selected.id
}

resource "aws_security_group" "rds" {
  name = "${var.namespace}-rds-sg"
  description = "RDS VPC Security Group to allow Reporting Service Ingress Traffic"
  vpc_id      = data.aws_vpc.selected.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_ingress_from_reporting_service" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = data.aws_security_group.reporting_service_rds.id
}