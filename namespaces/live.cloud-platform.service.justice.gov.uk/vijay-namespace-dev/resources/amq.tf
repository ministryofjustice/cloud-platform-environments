module "test_amq_broker_creation" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-amq-broker?ref=3.3"

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

resource "kubernetes_secret" "example_amq_broker" {
  metadata {
    name      = "test-amq-broker-creation"
    namespace = var.namespace
  }
  data = {
    password                   = module.test_amq_broker_creation.password
    primary_amqp_ssl_endpoint  = module.test_amq_broker_creation.primary_amqp_ssl_endpoint
    primary_stomp_ssl_endpoint = module.test_amq_broker_creation.primary_stomp_ssl_endpoint
    username                   = module.test_amq_broker_creation.username
  }
}
