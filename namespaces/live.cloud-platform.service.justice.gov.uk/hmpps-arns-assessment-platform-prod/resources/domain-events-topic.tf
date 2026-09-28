data "aws_ssm_parameter" "hmpps_domain_events_topic_arn" {
  name = "/hmpps-domain-events-prod/topic-arn"
}

resource "kubernetes_secret" "hmpps_domain_events_topic" {
  metadata {
    name      = "hmpps-domain-events-topic"
    namespace = var.namespace
  }
  data = {
    topic_arn = data.aws_ssm_parameter.hmpps_domain_events_topic_arn.value
  }
}