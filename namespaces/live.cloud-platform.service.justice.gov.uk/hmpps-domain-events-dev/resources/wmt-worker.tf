resource "kubernetes_secret" "wmt-worker" {
  metadata {
    name      = "wmt-hmpps-domain-events-topic"
    namespace = "hmpps-workload-dev"
  }

  data = {
    topic_arn = module.hmpps-domain-events.topic_arn
  }
}
