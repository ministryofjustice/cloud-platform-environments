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
    access_key_id     = module.test_amq_broker_creation.access_key_id
    secret_access_key = module.test_amq_broker_creation.secret_access_key
    # the above will not be set if existing_user_name is defined
    sqs_id   = module.test_amq_broker_creation.sqs_id
    sqs_arn  = module.test_amq_broker_creation.sqs_arn
    sqs_name = module.test_amq_broker_creation.sqs_name
  }
}
