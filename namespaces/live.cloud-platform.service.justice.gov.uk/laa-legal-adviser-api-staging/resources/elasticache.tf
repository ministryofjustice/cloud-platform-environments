module "celery-broker" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.2.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  application            = var.application
  is-production          = var.is_production
  business-unit          = var.business_unit
  node_type              = "cache.t2.micro"
  environment-name       = var.environment-name
  infrastructure-support = var.email
  engine_version         = "4.0.10"
  parameter_group_name   = "default.redis4.0"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "celery-broker" {
  metadata {
    name      = "celery-broker"
    namespace = var.namespace
  }

  data = {
    url                      = "redis://:${module.celery-broker.auth_token}@${module.celery-broker.primary_endpoint_address}:6379"
    primary_endpoint_address = module.celery-broker.primary_endpoint_address
    auth_token               = module.celery-broker.auth_token
  }
}
