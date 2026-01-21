module "redis" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=8.0.0" # use the latest release

  # VPC configuration
  vpc_name = var.vpc_name

  # Redis cluster configuration
  node_type               = "cache.t4g.micro"
  engine_version          = "7.0"
  parameter_group_name    = "default.redis7"
  auth_token_rotated_date = "2023-08-30"
  enable_irsa             = true

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
