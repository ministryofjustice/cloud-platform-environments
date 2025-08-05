module "sqs" {
  source                            = "./modules/sqs"
  queue_name                        = "rajinder-poc-sqs-queue"
  sqs_queue_subscriber_applications = ["CCMS USER MANAGEMENT"]
  business_unit                     = var.business_unit
  application                       = var.application
  is_production                     = var.is_production
  team_name                         = var.team_name
  namespace                         = var.namespace
  environment                       = var.environment
  infrastructure_support            = var.infrastructure_support
}