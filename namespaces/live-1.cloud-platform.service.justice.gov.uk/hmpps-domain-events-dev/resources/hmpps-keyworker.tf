
resource "kubernetes_secret" "keyworker_api_complexity_of_needs_queue" {
  metadata {
    name      = "hmpps-domain-events-topic"
    namespace = "keyworker-api-dev"
  }

  data = {
    access_key_id     = module.hmpps-domain-events.access_key_id
    secret_access_key = module.hmpps-domain-events.secret_access_key
    sqs_kw_url        = module.hmpps-domain-events.sqs_id
    sqs_kw_arn        = module.hmpps-domain-events.sqs_arn
    sqs_kw_name       = module.hmpps-domain-events.sqs_name
  }
}

resource "aws_sns_topic_subscription" "keyworker_api_complexity_of_needs_subscription" {
  provider      = aws.london
  topic_arn     = module.hmpps-domain-events.topic_arn
  protocol      = "sqs"
  endpoint      = module.hmpps-domain-events.sqs_arn
  filter_policy = "{\"eventType\":[\"new-complexity-of-need-level\"]}"
}

