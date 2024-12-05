# Get VPC id
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name == "live" ? "live-1" : var.vpc_name]
  }
}

# Additional RDS SG
resource "aws_security_group" "rds" {
  name          = "cloudplatform-mp-dps-sg"
  description   = "RDS VPC Security Group for MP Ingress Traffic"
  vpc_id        = data.aws_vpc.selected.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "rule" {
  cidr_blocks       = ["10.26.24.0/21", "10.26.8.0/21", "10.27.0.0/21", "10.27.8.0/21"]
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 5432
  to_port           = 5432
  security_group_id = aws_security_group.rds.id
}
