module "hmpps_strengths_based_needs_assessments_dev_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  db_allocated_storage   = 20
  storage_type           = "gp3"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  rds_family             = "postgres18"
  db_instance_class      = "db.t4g.small"
  db_engine              = "postgres"
  db_engine_version      = "18.6" 

  allow_major_version_upgrade = "true"
  prepare_for_major_upgrade   = false

  providers = {
    aws = aws.london
  }

  vpc_security_group_ids = [module.rds_security_group.security_group_id]

  enable_irsa = true
}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

module "rds_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.2.0"

  name = "sbna_modernisation_platform_access"

  vpc_id = data.aws_vpc.this.id

  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = "10.26.8.0/21"
    },

  ]
}

resource "kubernetes_secret" "hmpps_strengths_based_needs_assessments_dev_rds_secret" {
  metadata {
    name      = "hmpps-strengths-based-needs-assessments-rds-instance"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps_strengths_based_needs_assessments_dev_rds.rds_instance_endpoint
    database_name         = module.hmpps_strengths_based_needs_assessments_dev_rds.database_name
    database_username     = module.hmpps_strengths_based_needs_assessments_dev_rds.database_username
    database_password     = module.hmpps_strengths_based_needs_assessments_dev_rds.database_password
    rds_instance_address  = module.hmpps_strengths_based_needs_assessments_dev_rds.rds_instance_address
    url                   = "postgres://${module.hmpps_strengths_based_needs_assessments_dev_rds.database_username}:${module.hmpps_strengths_based_needs_assessments_dev_rds.database_password}@${module.hmpps_strengths_based_needs_assessments_dev_rds.rds_instance_endpoint}/${module.hmpps_strengths_based_needs_assessments_dev_rds.database_name}"
  }
}
