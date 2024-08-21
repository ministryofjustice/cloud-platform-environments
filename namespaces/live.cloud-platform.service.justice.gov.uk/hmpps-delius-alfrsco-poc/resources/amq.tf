module "alfresco_amq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-amq-broker?ref=3.4"

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = "false"
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  providers = {
    # This can be either "aws.london" or "aws.ireland:
     aws = aws.london
  }
}


resource "kubernetes_secret" "alfresco_amq" {
  metadata {
    name      = "alfresco-amq-broker-output"
    namespace = var.namespace
  }

  data = {
    AMQ_BROKER_URL = module.alfresco_amq.broker_url
    AMQ_BROKER_USERNAME = module.alfresco_amq.broker_username
    AMQ_BROKER_PASSWORD = module.alfresco_amq.broker_password
  }
}
