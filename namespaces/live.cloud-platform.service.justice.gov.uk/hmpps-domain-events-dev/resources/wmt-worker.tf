resource "kubernetes_secret" "wmt-worker" {
  metadata {
    name      = "wmt-hmpps-domain-events-topic"
    namespace = "hmpps-workload-dev"
  }

  data = {
    access_key_id     = module.hmpps-domain-events.access_key_id
    secret_access_key = module.hmpps-domain-events.secret_access_key
    topic_arn         = module.hmpps-domain-events.topic_arn
    sqs_queue_url     = module.hmpps-domain-events.sqs_id
  }
}
