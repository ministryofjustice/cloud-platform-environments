module "alfresco_amq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-amq-broker?ref=3.4"

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = "false"
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  namespace    = var.namespace
  cluster_name = var.eks_cluster_name

  engine_type        = "ActiveMQ"
  engine_version     = "5.18"
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
    BROKER_URL      = module.alfresco_amq.primary_amqp_ssl_endpoint
    BROKER_USERNAME = module.alfresco_amq.username
    BROKER_PASSWORD = module.alfresco_amq.password
  }
  depends_on = [ module.alfresco_amq ]
}
