module "redis_4" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.0.0"

  // Redis 4 config
  engine_version       = "6.2"
  parameter_group_name = "default.redis6.x"
  node_type            = "cache.t4g.micro"

  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

module "redis_5" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.0.0"

  // Redis 5 config
  engine_version       = "6.2"
  parameter_group_name = "default.redis6.x"
  node_type            = "cache.t4g.micro"

  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

module "redis_6" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.0.0"

  // Redis 6 config
  engine_version       = "6.2"
  parameter_group_name = "default.redis6.x"
  node_type            = "cache.t4g.micro"

  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

module "redis_6_2" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.0.0"

  // Redis 6.2 config
  engine_version       = "6.2"
  parameter_group_name = "default.redis6.x"
  node_type            = "cache.t4g.micro"

  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

module "redis_7_0" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.0.0"

  // Redis 7.0 config
  engine_version       = "7.0"
  parameter_group_name = "default.redis7"
  node_type            = "cache.t4g.micro"

  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}
