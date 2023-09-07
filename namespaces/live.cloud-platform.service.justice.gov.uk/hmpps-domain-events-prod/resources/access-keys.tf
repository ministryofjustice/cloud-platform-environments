resource "kubernetes_secret" "additional_secrets" {
  for_each = toset(var.additional_topic_clients)
  metadata {
    name      = "hmpps-domain-events-topic"
    namespace = each.value
  }
  data = {
    topic_arn = module.hmpps-domain-events.topic_arn
  }
}
