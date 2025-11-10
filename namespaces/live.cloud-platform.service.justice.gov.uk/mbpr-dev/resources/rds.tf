module "rds_instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # Database configuration
  db_engine                = "postgres"
  db_engine_version        = "17.4"
  rds_family               = "postgres17"
  db_instance_class        = "db.t4g.micro"
  db_max_allocated_storage = "500"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}