resource "kubernetes_secret" "wmt-worker" {
  metadata {
    name      = "wmt-hmpps-domain-events-topic"
    namespace = "hmpps-workload-prod"
  }

  data = {
    access_key_id     = module.hmpps-domain-events.access_key_id
    secret_access_key = module.hmpps-domain-events.secret_access_key
    topic_arn         = module.hmpps-domain-events.topic_arn
  }
}
