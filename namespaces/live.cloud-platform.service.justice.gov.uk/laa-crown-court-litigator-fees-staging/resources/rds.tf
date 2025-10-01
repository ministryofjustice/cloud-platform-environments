module "rds-instance-migrated" {
  source   = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
  vpc_name = var.vpc_name

  application            = var.application
  environment_name       = var.environment
  is_production          = var.is_production
  namespace              = var.namespace
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  business_unit          = var.business_unit

  enable_rds_auto_start_stop = false

  # Database configuration
  db_engine                = "oracle-se2"
  db_engine_version        = "19.0.0.0.ru-2025-07.rur-2025-07.r1"
  rds_family               = "oracle-se2-19"
  db_instance_class        = "db.t3.medium"
  storage_type             = "gp2"
  db_allocated_storage     = "300"
  db_max_allocated_storage = "500"
  db_name                  = "CCLF"
  license_model            = "license-included"
  db_iops                  = 0
  character_set_name       = "WE8MSWIN1252"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "false"

  # enable performance insights
  performance_insights_enabled = false

  snapshot_identifier = "arn:aws:rds:eu-west-2:754256621582:snapshot:cclf-staging-cp-migration-snapshot-11-11-24"

  providers = {
    aws = aws.london
  }

  db_parameter = [
    {
      name         = "sqlnetora.sqlnet.allowed_logon_version_server"
      value        = "10"
      apply_method = "immediate"
    },
    {
      name         = "remote_dependencies_mode"
      value        = "SIGNATURE"
      apply_method = "immediate"
    }
  ]

  vpc_security_group_ids = [aws_security_group.rds.id]
  is_migration = true


  enable_irsa = true
}


# Get VPC id
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name == "live" ? "live-1" : var.vpc_name]
  }
}

# Additional RDS SG
resource "aws_security_group" "rds" {
  name        = "${var.namespace}-RDS-${var.environment}"
  description = "RDS VPC Security Group for  Ingress Traffic"
  vpc_id      = data.aws_vpc.selected.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "rule1" {
  cidr_blocks       = ["10.204.0.0/20"]
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 1521
  to_port           = 1521
  security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "rule2" {
  cidr_blocks       = ["10.204.0.0/20"]
  type              = "egress"
  protocol          = "tcp"
  from_port         = 1521
  to_port           = 1521
  security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "rule3" {
  cidr_blocks       = ["10.200.16.0/20"]
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 1521
  to_port           = 1521
  security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "rule4" {
  cidr_blocks       = ["10.200.16.0/20"]
  type              = "egress"
  protocol          = "tcp"
  from_port         = 1521
  to_port           = 1521
  security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "rule5" {
  cidr_blocks       = ["10.205.0.0/20"]
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 1521
  to_port           = 1521
  security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "rule6" {
  cidr_blocks       = ["10.205.0.0/20"]
  type              = "egress"
  protocol          = "tcp"
  from_port         = 1521
  to_port           = 1521
  security_group_id = aws_security_group.rds.id
}

# Allow MojFin to extract data from the CCLF database for reporting
resource "aws_security_group_rule" "mp_staging_subnet_data_2a" {
  cidr_blocks       = ["10.27.77.128/25"]
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 1521
  to_port           = 1521
  security_group_id = aws_security_group.rds.id
  description       = "Modernisation Platform staging data subnet 2a to connect CCLF DB"
}

# Allow MojFin to extract data from the CCLF database for reporting
resource "aws_security_group_rule" "mp_staging_subnet_data_2b" {
  cidr_blocks       = ["10.27.76.128/25"]
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 1521
  to_port           = 1521
  security_group_id = aws_security_group.rds.id
  description       = "Modernisation Platform staging data subnet 2b to connect CCLF DB"
}

# Allow MojFin to extract data from the CCLF database for reporting
resource "aws_security_group_rule" "mp_staging_subnet_data_2c" {
  cidr_blocks       = ["10.27.77.0/25"]
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 1521
  to_port           = 1521
  security_group_id = aws_security_group.rds.id
  description       = "Modernisation Platform staging data subnet 2c to connect CCLF DB"
}

resource "kubernetes_secret" "rds-instance" {
  metadata {
    name      = "rds-cclf-${var.environment}"
    namespace = var.namespace
  }

  data = {
    database_name     = module.rds-instance-migrated.database_name
    database_host     = module.rds-instance-migrated.rds_instance_address
    database_port     = module.rds-instance-migrated.rds_instance_port
    database_username = module.rds-instance-migrated.database_username
    database_password = module.rds-instance-migrated.database_password
  }
}