data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name == "live" ? "live-1" : var.vpc_name]
  }
}

resource "aws_security_group" "data_factory_rds" {
  name        = "data-factory-mp-cp-sg"
  description = "Allow data-factory-moj-dev connectivity to RDS"
  vpc_id      = data.aws_vpc.selected.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "data_factory_ingress" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 5432
  to_port           = 5432
  cidr_blocks       = ["10.26.16.0/21"]
  security_group_id = aws_security_group.data_factory_rds.id
}

resource "aws_security_group_rule" "data_factory_egress" {
  type              = "egress"
  protocol          = "tcp"
  from_port         = 5432
  to_port           = 5432
  cidr_blocks       = ["10.26.16.0/21"]
  security_group_id = aws_security_group.data_factory_rds.id
}