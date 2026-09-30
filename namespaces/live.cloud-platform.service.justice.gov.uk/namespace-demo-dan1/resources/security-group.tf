data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name == "live" ? "live-1" : var.vpc_name]
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.namespace}-rds-sg"
  description = "Allow Container Platform access to this database"
  vpc_id      = data.aws_vpc.selected.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "rds_inbound" {
  type              = "ingress"
  description       = "Container Platform nonlive"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.rds.id
  cidr_blocks       = ["10.195.48.0/20"] # container-platform-octo-nonlive
}