resource "kubernetes_secret" "additional_secrets" {
  for_each = toset(var.additional_topic_clients)
  metadata {
    name      = "hmpps-domain-events-topic"
    namespace = each.value
  }
  data = {
    access_key_id     = module.hmpps-domain-events.additional_access_keys[each.value].access_key_id
    secret_access_key = module.hmpps-domain-events.additional_access_keys[each.value].secret_access_key
    topic_arn         = module.hmpps-domain-events.topic_arn
  }
}