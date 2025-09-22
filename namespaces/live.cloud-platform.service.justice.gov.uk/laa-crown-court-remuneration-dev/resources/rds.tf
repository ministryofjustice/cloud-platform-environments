module "rds-mtn" {
  source   = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.0.0"
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
  db_name                  = "CCR"
  license_model            = "license-included"
  db_iops                  = 0
  character_set_name       = "WE8MSWIN1252"
  skip_final_snapshot      = true
  db_password_rotated_date = "2025-05-29"
  option_group_name        = aws_db_option_group.rds_s3_option_group.name

  # the database is being migrated from another hosting platform
  is_migration = true

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "false"

  # enable performance insights
  performance_insights_enabled = false

  snapshot_identifier = "arn:aws:rds:eu-west-2:754256621582:snapshot:ccr-dev-cp-migration-21062024-manual-copy"

  providers = {
    aws = aws.london
  }

  # passing emplty list as oracle repo has parameter defined
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
  cidr_blocks       = ["10.202.0.0/20"]
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 1521
  to_port           = 1521
  security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "rule2" {
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

# Allow the Hub 2.0 Lambda move provider details into the CCR database
# Allow MojFin to extract data fromt he CCR database for reporting
resource "aws_security_group_rule" "mp_dev_subnet_data_2a" {
  cidr_blocks       = ["10.26.60.128/25"]
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 1521
  to_port           = 1521
  security_group_id = aws_security_group.rds.id
  description       = "Modernisation Platform dev data subnet 2a to connect CCR DB"
}

# Allow MojFin to extract data fromt he CCR database for reporting
resource "aws_security_group_rule" "mp_dev_subnet_data_2b" {
  cidr_blocks       = ["10.26.61.0/25"]
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 1521
  to_port           = 1521
  security_group_id = aws_security_group.rds.id
  description       = "Modernisation Platform dev data subnet 2b to connect CCR DB"
}

# Allow MojFin to extract data fromt he CCR database for reporting
resource "aws_security_group_rule" "mp_dev_subnet_data_2c" {
  cidr_blocks       = ["10.26.61.128/25"]
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 1521
  to_port           = 1521
  security_group_id = aws_security_group.rds.id
  description       = "Modernisation Platform dev data subnet 2c to connect CCR DB"
}

#RDS role to access HUB 2.0 S3 Bucket
resource "aws_iam_role" "rds_s3_access" {
  name = "ccr-rds-hub20-s3-access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "rds.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "rds_s3_access_policy" {
  name        = "ccr-rds-hub20-s3-bucket-policy"
  description = "Allow Oracle RDS instance to read objects from HUB 2.0 S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:GetObjectVersion",
          "s3:ListBucket",
          "s3:ListBucketVersions"
        ],
        Resource = [
          "arn:aws:s3:::hub20-development-cwa-extract-data",
          "arn:aws:s3:::hub20-development-cwa-extract-data/*"  
        ]
      }
    ]
  })
}

resource "aws_db_option_group" "rds_s3_option_group" {
  name                     = "${var.namespace}-option-group"
  option_group_description = "Option group with S3 integration"
  engine_name              = "oracle-se2"
  major_engine_version     = "19"

  option {
    option_name = "S3_INTEGRATION"
  }

  tags = {
    name                   = "${var.namespace}-option-group"
    application            = var.application
    business_unit          = var.business_unit
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
    is_production          = var.is_production
    namespace              = var.namespace
    team_name              = var.team_name
  }
}

resource "aws_iam_role_policy_attachment" "rds_s3_access_policy_attachment" {
  role       = aws_iam_role.rds_s3_access.name
  policy_arn = aws_iam_policy.rds_s3_access_policy.arn
}

resource "aws_db_instance_role_association" "rds_s3_role_association" {
  db_instance_identifier = module.rds-mtn.db_identifier
  feature_name           = "S3_INTEGRATION"
  role_arn               = aws_iam_role.rds_s3_access.arn
}

resource "kubernetes_secret" "rds-instance" {
  metadata {
    name      = "rds-ccr-${var.environment}"
    namespace = var.namespace
  }

  data = {
    database_name     = module.rds-mtn.database_name
    database_host     = module.rds-mtn.rds_instance_address
    database_port     = module.rds-mtn.rds_instance_port
    database_username = module.rds-mtn.database_username
    database_password = module.rds-mtn.database_password
  }
}
