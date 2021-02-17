resource "kubernetes_secret" "intervention_global_events_sns" {
  metadata {
    name      = "hmpps-domain-events-topic"
    namespace = "hmpps-interventions-prod"
  }

  data = {
    access_key_id     = module.hmpps-domain-events.access_key_id
    secret_access_key = module.hmpps-domain-events.secret_access_key
    topic_arn         = module.hmpps-domain-events.topic_arn
  }
}
