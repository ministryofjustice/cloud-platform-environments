resource "kubernetes_secret" "hmpps-incentives" {
  metadata {
    name      = "hmpps-domain-events-topic"
    namespace = "hmpps-incentives-dev"
  }

  data = {
    access_key_id     = module.hmpps-domain-events.additional_access_keys["hmpps-incentives"].access_key_id
    secret_access_key = module.hmpps-domain-events.additional_access_keys["hmpps-incentives"].secret_access_key
    topic_arn         = module.hmpps-domain-events.topic_arn
  }
}
