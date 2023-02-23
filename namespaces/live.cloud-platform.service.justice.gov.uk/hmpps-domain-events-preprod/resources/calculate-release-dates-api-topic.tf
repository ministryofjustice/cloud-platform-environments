resource "kubernetes_secret" "calculate-release-dates-api-topic" {
  metadata {
    name      = "hmpps-domain-events-topic"
    namespace = "calculate-release-dates-api-preprod"
  }

  data = {
    access_key_id     = module.hmpps-domain-events.access_key_id
    secret_access_key = module.hmpps-domain-events.secret_access_key
    topic_arn         = module.hmpps-domain-events.topic_arn
  }
}
