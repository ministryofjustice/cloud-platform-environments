module "rds-instance" {
  source   =  "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=add-oracle"
  vpc_name = var.vpc_name

  application            = var.application
  environment_name       = var.environment
  is_production          = var.is_production
  namespace              = var.namespace
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  business_unit          = var.business_unit

  enable_rds_auto_start_stop = true


 # Database configuration
  db_engine                = "oracle-se2" # or oracle-ee
  db_engine_version        = "19.0.0.0.ru-2019-07.rur-2019-07.r1"
  rds_family               = "oracle-se2-19"
  db_instance_class        = "db.t3.medium"
  db_allocated_storage     = "300"
  db_max_allocated_storage = "500"
  db_name                  = "CCR"
  license_model = "license-included"
  db_iops = 0
  character_set_name = "WE8MSWIN1252"   # problem  
 
  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "false"

  # enable performance insights
  performance_insights_enabled = true

  snapshot_identifier = "ccr-sandbox-dev-encrypted-for-cp"

  providers = {
    aws = aws.london
  }

  # passing emplty list as oracle repo has parameter defined 
  db_parameter = []

  vpc_security_group_ids = [aws_security_group.rds.id]
  
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
  name          = "${var.namespace}-RDS-${var.environment}"
  description   = "RDS VPC Security Group for  Ingress Traffic"
  vpc_id        = data.aws_vpc.selected.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "rule" {
  cidr_blocks       = ["10.202.0.0/20"]
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 1521
  to_port           = 1521
  security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "ruleb" {
  cidr_blocks       = ["10.202.0.0/20"]
  type              = "egress"
  protocol          = "tcp"
  from_port         = 1521
  to_port           = 1521
  security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "rule3" {
  cidr_blocks       = ["10.200.0.0/20"]
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 1521
  to_port           = 1521
  security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "rule4" {
  cidr_blocks       = ["10.200.0.0/20"]
  type              = "egress"
  protocol          = "tcp"
  from_port         = 1521
  to_port           = 1521
  security_group_id = aws_security_group.rds.id
}



resource "kubernetes_secret" "rds-instance" {
  metadata {
    name      = "rds-instance-calculate-journey-variable-payments-${var.environment}"
    namespace = var.namespace
  }

  data = {
    database_name     = module.rds-instance.database_name
    database_host     = module.rds-instance.rds_instance_address
    database_port     = module.rds-instance.rds_instance_port
    database_username = module.rds-instance.database_username
    database_password = module.rds-instance.database_password
  }
}
