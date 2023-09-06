resource "kubernetes_secret" "wmt-worker" {
  metadata {
    name      = "wmt-hmpps-domain-events-topic"
    namespace = "hmpps-workload-prod"
  }

  data = {
    topic_arn = module.hmpps-domain-events.topic_arn
  }
}
