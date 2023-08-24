resource "kubernetes_secret" "oasys_access_key_secret" {
  metadata {
    name      = "hmpps-domain-events-topic-oasys"
    namespace = var.namespace
  }
  data = {
    access_key_id     = module.hmpps-domain-events.additional_access_keys["oasys"].access_key_id
    secret_access_key = module.hmpps-domain-events.additional_access_keys["oasys"].secret_access_key
    topic_arn         = module.hmpps-domain-events.topic_arn
  }
}
