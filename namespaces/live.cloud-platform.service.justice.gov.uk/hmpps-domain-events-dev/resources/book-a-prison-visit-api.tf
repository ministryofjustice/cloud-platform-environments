resource "kubernetes_secret" "book-a-prison-visit-api" {
  metadata {
    name      = "hmpps-domain-events-topic"
    namespace = "book-a-prison-visit-api-dev"
  }

  data = {
    access_key_id     = module.hmpps-domain-events.access_key_id
    secret_access_key = module.hmpps-domain-events.secret_access_key
    topic_arn         = module.hmpps-domain-events.topic_arn
  }
}
