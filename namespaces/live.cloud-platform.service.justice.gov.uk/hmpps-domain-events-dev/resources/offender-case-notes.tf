resource "kubernetes_secret" "topic_secrets" {
  metadata {
    namespace = "offender-case-notes-${var.environment-name}"
    name      = "domain-events-topic"
  }

  data = {
    topic_arn         = module.hmpps-domain-events.topic_arn
    access_key_id     = module.hmpps-domain-events.access_key_id
    secret_access_key = module.hmpps-domain-events.secret_access_key
  }
}

