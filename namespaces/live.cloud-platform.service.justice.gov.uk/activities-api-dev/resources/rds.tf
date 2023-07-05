module "activities_api_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.19.0"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business-unit               = var.business_unit
  application                 = var.application
  is-production               = var.is_production
  namespace                   = var.namespace
  environment-name            = var.environment
  infrastructure-support      = var.infrastructure_support
  rds_family                  = var.rds_family
  allow_major_version_upgrade = "false"
  db_instance_class           = "db.t3.small"
  db_engine_version           = "14"
  vpc_security_group_ids      = [aws_security_group.rds.id]


  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "activities_api_rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.activities_api_rds.rds_instance_endpoint
    database_name         = module.activities_api_rds.database_name
    database_username     = module.activities_api_rds.database_username
    database_password     = module.activities_api_rds.database_password
    rds_instance_address  = module.activities_api_rds.rds_instance_address
    access_key_id         = module.activities_api_rds.access_key_id
    secret_access_key     = module.activities_api_rds.secret_access_key
  }
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
  name_prefix = "${module.activities_api_rds.database_name}-mp-sg"
  description = "RDS VPC Security Group for MP Ingress Traffic"
  vpc_id      = aws_vpc.selected.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "rule" {
  cidr_blocks       = ["10.26.24.0/21"]
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 5432
  to_port           = 5432
  security_group_id = aws_security_group.rds.id
}