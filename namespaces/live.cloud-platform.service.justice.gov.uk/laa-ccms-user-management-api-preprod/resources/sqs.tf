module "sqs" {
  source                          = "./modules/sqs"
  queue_name                      = "${var.namespace}-sqs-queue"
  sqs_queue_subscriber_namespaces = ["laa-landing-page-preprod"]
  fifo_queue                      = true
  dlq_max_receive_count           = 28
  visibility_timeout_seconds      = 30
  message_retention_seconds       = 1209600
  max_message_size                = 262144
  delay_seconds                   = 1

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment            = var.environment
  infrastructure_support = var.infrastructure_support
}
