module "simulated_data_producer_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.17.0"

  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  # TODO: Instance configuration
  rds_name = "simulated-data-producer"  

  providers = {
    aws = aws.london
  }
}