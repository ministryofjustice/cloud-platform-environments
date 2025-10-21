# Retrieve mp_dps_sg_name SG group ID
data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}

module "edu_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
  db_allocated_storage        = 10
  storage_type                = "gp2"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support
  prepare_for_major_upgrade   = true
  allow_major_version_upgrade = true
  db_engine                   = "postgres"
  db_instance_class           = "db.t4g.micro"
  db_max_allocated_storage    = "500"
  db_engine_version           = "16"
  rds_family                  = "postgres16"
  enable_rds_auto_start_stop  = true
  enable_irsa                 = true
  vpc_security_group_ids      = [data.aws_security_group.mp_dps_sg.id]

  providers = {
    aws = aws.london
  }

}

resource "kubernetes_secret" "edu_rds" {
  metadata {
    name      = "edu-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.edu_rds.rds_instance_endpoint
    database_name         = module.edu_rds.database_name
    database_username     = module.edu_rds.database_username
    database_password     = module.edu_rds.database_password
    rds_instance_address  = module.edu_rds.rds_instance_address
    url                   = "postgres://${module.edu_rds.database_username}:${module.edu_rds.database_password}@${module.edu_rds.rds_instance_endpoint}/${module.edu_rds.database_name}"
  }
}
