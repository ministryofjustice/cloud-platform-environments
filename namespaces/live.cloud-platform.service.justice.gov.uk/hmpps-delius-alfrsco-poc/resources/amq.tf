module "alfresco_amq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-amq-broker"

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = "false"
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  engine_type        = "ActiveMQ"
  engine_version     = "5.18.4"
  host_instance_type = "mq.m5.large"
  deployment_mode    = "ACTIVE_STANDBY_MULTI_AZ"


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
    BROKER_URL      = module.alfresco_amq.broker_url
    BROKER_USERNAME = module.alfresco_amq.broker_username
    BROKER_PASSWORD = module.alfresco_amq.broker_password
  }
}
