data "aws_sns_topic" "hmpps-domain-events" {
  name = var.domain_events_topic_name
}

resource "kubernetes_secret" "topic-secret" {
  metadata {
    namespace = var.namespace
    name      = "hmpps-domain-events"
  }
  data = {
    topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  }
}
