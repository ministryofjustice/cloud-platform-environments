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

  clients = ["mapps", "heartbeat", "ctrlo", "pnd", "event-service", "mryall", "moj-pes", "maspin", "kilco", "meganexus","bmadley"]
  client_queues = {
    "mapps.client.org" = module.event_mapps_queue.sqs_name
    pnd                = module.event_pnd_queue.sqs_name
    maspin             = module.event_pnd_queue.sqs_name # testing
    mryall             = module.event_pnd_queue.sqs_name # testing
    meganexus          = module.event_plp_queue.sqs_name
  }
}
