module "test_amq_broker" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-amq-broker?ref=3.1"

  team_name              = "test-names"
  business-unit          = "HQ"
  application            = "cloud platform"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "platforms@digital.justice.gov.uk"
  namespace              = "abundant-namespace-dev"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "example_team_broker" {
  metadata {
    name      = "example-team-broker-output"
    namespace = "abundant-namespace-dev"
  }

  data = {
    primary_amqp_ssl_endpoint  = module.test_amq_broker.primary_amqp_ssl_endpoint
    primary_stomp_ssl_endpoint = module.test_amq_broker.primary_stomp_ssl_endpoint
    username                   = module.test_amq_broker.username
    password                   = module.test_amq_broker.password
  }
}
