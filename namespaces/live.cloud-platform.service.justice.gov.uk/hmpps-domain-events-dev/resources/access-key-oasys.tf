resource "kubernetes_secret" "oasys_access_key_secret" {
  metadata {
    name      = "hmpps-domain-events-topic-oasys"
    namespace = var.namespace
  }
  data = {
    topic_arn = module.hmpps-domain-events.topic_arn
  }
}
