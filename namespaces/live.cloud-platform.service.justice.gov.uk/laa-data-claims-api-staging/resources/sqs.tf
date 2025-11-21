
module "sqs_queue" {
  source                            = "./modules/sqs"
  queue_name                        = "claims-api-sqs-queue"
  sqs_queue_subscriber_namespaces = ["laa-data-claims-event-service-staging"]
  business_unit                     = var.business_unit
  application                       = var.application
  is_production                     = var.is_production
  team_name                         = var.team_name
  namespace                         = var.namespace
  environment                       = var.environment
  infrastructure_support            = var.infrastructure_support
  visibility_timeout_seconds        = 600
}
