resource "kubernetes_secret" "manage-pom-cases" {
  metadata {
    name      = "hmpps-domain-events-topic-manage-pom-cases"
    namespace = var.namespace
    # Remove when namespace has been migrated
    # name      = "hmpps-domain-events-topic"
    # namespace = "offender-management-staging"
  }

  data = {
    access_key_id     = module.hmpps-domain-events.access_key_id
    secret_access_key = module.hmpps-domain-events.secret_access_key
    topic_arn         = module.hmpps-domain-events.topic_arn
  }
}
