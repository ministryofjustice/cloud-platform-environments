data "aws_vpc" "db_bastion" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name == "live" ? "live-1" : var.vpc_name]
  }
}

data "aws_subnets" "db_bastion_private" {
  filter {
    name   = "tag:SubnetType"
    values = ["Private"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.db_bastion.id]
  }
}

data "aws_ssm_parameter" "windows_server_2022" {
  name = "/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base"
}

data "aws_iam_policy_document" "db_bastion_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "db_bastion" {
  name               = "${var.namespace}-db-bastion"
  assume_role_policy = data.aws_iam_policy_document.db_bastion_assume_role.json
}

resource "aws_iam_role_policy_attachment" "db_bastion_ssm" {
  role       = aws_iam_role.db_bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "db_bastion" {
  name = "${var.namespace}-db-bastion"
  role = aws_iam_role.db_bastion.name
}

resource "aws_security_group" "db_bastion" {
  name        = "${var.namespace}-db-bastion"
  description = "Windows database bastion managed through AWS Systems Manager"
  vpc_id      = data.aws_vpc.db_bastion.id

  tags = {
    Name = "${var.namespace}-db-bastion"
  }
}

resource "aws_security_group" "db_bastion_oracle_access" {
  name        = "${var.namespace}-db-bastion-oracle-access"
  description = "Allow the database bastion to reach the Oracle RDS listener"
  vpc_id      = data.aws_vpc.db_bastion.id

  tags = {
    Name = "${var.namespace}-db-bastion-oracle-access"
  }
}

resource "aws_vpc_security_group_egress_rule" "db_bastion_ssm" {
  security_group_id = aws_security_group.db_bastion.id
  description       = "Allow Systems Manager connectivity"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "db_bastion_oracle" {
  security_group_id            = aws_security_group.db_bastion.id
  description                  = "Allow Oracle database connectivity"
  ip_protocol                  = "tcp"
  from_port                    = 1521
  to_port                      = 1521
  referenced_security_group_id = aws_security_group.db_bastion_oracle_access.id
}

resource "aws_vpc_security_group_ingress_rule" "db_bastion_oracle" {
  security_group_id            = aws_security_group.db_bastion_oracle_access.id
  description                  = "Allow Oracle connections from the database bastion"
  ip_protocol                  = "tcp"
  from_port                    = 1521
  to_port                      = 1521
  referenced_security_group_id = aws_security_group.db_bastion.id
}

resource "aws_instance" "db_bastion" {
  ami                         = data.aws_ssm_parameter.windows_server_2022.value
  instance_type               = "t3.large"
  subnet_id                   = sort(data.aws_subnets.db_bastion_private.ids)[0]
  vpc_security_group_ids      = [aws_security_group.db_bastion.id]
  iam_instance_profile        = aws_iam_instance_profile.db_bastion.name
  associate_public_ip_address = false
  ebs_optimized               = true
  monitoring                  = true

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_type           = "gp3"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  tags = {
    Name = "${var.namespace}-db-bastion"
  }

  volume_tags = {
    Name = "${var.namespace}-db-bastion"
  }

  depends_on = [aws_iam_role_policy_attachment.db_bastion_ssm]

  lifecycle {
    ignore_changes = [ami]
  }
}