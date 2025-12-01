locals {
  default_tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }

  clients = ["ctrlo", "heartbeat", "event-service", "moj-pes", "meganexus", "pnd", "pmcphee", "smoke-test", "smartinbox"]

  client_queues = {
    meganexus          = module.event_plp_queue.sqs_name
    pnd                = module.event_pnd_queue.sqs_name
  }
}
