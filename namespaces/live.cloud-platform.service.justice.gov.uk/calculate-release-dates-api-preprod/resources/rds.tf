data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

resource "aws_security_group" "data_catalogue_access_sg" {
  name        = "${var.namespace}-RDS-DC-Access-SG"
  description = "Security Group for Data Catalogue access to RDS"
  vpc_id      = data.aws_vpc.this.id

  lifecycle {
    create_before_destroy = true
  }

  ingress{
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = ["10.201.128.0/17"]
  }
}

data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}
