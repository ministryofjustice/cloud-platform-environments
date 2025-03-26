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
  name = "cloud-platform-Digital-Prison-Services-15b2b4a6af7714848baeaf5f41c85fcd"
}