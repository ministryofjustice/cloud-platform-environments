resource "kubernetes_secret" "hmpps_cas_domain_events_topic" {
  metadata {
    name      = "hmpps-domain-events-topic-cas"
    namespace = var.namespace
  }

  data = {
    topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  }
}

data "aws_sns_topic" "hmpps-domain-events" {
  name = "cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573"
}