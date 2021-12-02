resource "kubernetes_secret" "prison-offender-events" {
  metadata {
    name      = "hmpps-domain-events-topic"
    namespace = "offender-events-preprod"
  }

  data = {
    access_key_id     = module.hmpps-domain-events.access_key_id
    secret_access_key = module.hmpps-domain-events.secret_access_key
    topic_arn         = module.hmpps-domain-events.topic_arn
  }
}
