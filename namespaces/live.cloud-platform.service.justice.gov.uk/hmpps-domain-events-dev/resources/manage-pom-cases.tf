resource "kubernetes_secret" "manage-pom-cases-staging" {
  metadata {
    name      = "hmpps-domain-events-topic"
    namespace = "offender-management-staging"
  }

  data = {
    access_key_id     = module.hmpps-domain-events.access_key_id
    secret_access_key = module.hmpps-domain-events.secret_access_key
    topic_arn         = module.hmpps-domain-events.topic_arn
  }
}

resource "kubernetes_secret" "manage-pom-cases-test" {
  metadata {
    name      = "hmpps-domain-events-topic"
    namespace = "offender-management-test"
  }

  data = {
    access_key_id     = module.hmpps-domain-events.access_key_id
    secret_access_key = module.hmpps-domain-events.secret_access_key
    topic_arn         = module.hmpps-domain-events.topic_arn
  }
}

resource "kubernetes_secret" "manage-pom-cases-test2" {
  metadata {
    name      = "hmpps-domain-events-topic"
    namespace = "offender-management-test2"
  }

  data = {
    access_key_id     = module.hmpps-domain-events.access_key_id
    secret_access_key = module.hmpps-domain-events.secret_access_key
    topic_arn         = module.hmpps-domain-events.topic_arn
  }
}
