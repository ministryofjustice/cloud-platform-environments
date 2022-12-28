module "redis_4" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=5.5"

  // Redis 4 config
  engine_version = "4.0.10"
  parameter_group_name = "default.redis4.0"

  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "redis_5" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=5.5"

  // Redis 5 config
  engine_version = "5.0.6"
  parameter_group_name = "default.redis5.0"

  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "redis_6" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=5.5"

  // Redis 6 config
  engine_version = "6.0"
  parameter_group_name = "default.redis6.x"

  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "redis_6_2" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=5.5"

  // Redis 6.2 config
  engine_version = "6.2"
  parameter_group_name = "default.redis6.x"

  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}
