# Get VPC id
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name == "live" ? "live-1" : var.vpc_name]
  }
}

resource "aws_security_group" "source_rds" {
  name = "${var.namespace}-rds-sg"
  description = "RDS VPC Security Group to allow Reporting Service Ingress Traffic"
  vpc_id      = data.aws_vpc.selected.id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port                = 5432
    to_port                  = 5432
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.laa-data-claims-reporting-service-uat-rds-sg.id
  }
}