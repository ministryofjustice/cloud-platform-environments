resource "kubernetes_secret" "make-recall-decision-api" {
  metadata {
    name      = "hmpps-domain-events-topic"
    namespace = "make-recall-decision-preprod"
  }

  data = {
    access_key_id     = module.hmpps-domain-events.access_key_id
    secret_access_key = module.hmpps-domain-events.secret_access_key
    topic_arn         = module.hmpps-domain-events.topic_arn
  }
}
