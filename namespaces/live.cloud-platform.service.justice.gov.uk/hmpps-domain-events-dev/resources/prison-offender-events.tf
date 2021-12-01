resource "kubernetes_secret" "prison-offender-events" {
  metadata {
    name      = "hmpps-domain-events-topic"
    namespace = var.namespace
    # Remove when namespace has been migrated
    # namespace = "offender-events-dev"
  }

  data = {
    access_key_id     = module.hmpps-domain-events.access_key_id
    secret_access_key = module.hmpps-domain-events.secret_access_key
    topic_arn         = module.hmpps-domain-events.topic_arn
  }
}
