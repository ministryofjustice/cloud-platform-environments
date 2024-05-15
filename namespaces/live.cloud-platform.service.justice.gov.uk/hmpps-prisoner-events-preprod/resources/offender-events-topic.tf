resource "kubernetes_secret" "hmpps_offender_events_topic" {
  metadata {
    name      = "offender-events-topic"
    namespace = var.namespace
  }

  data = {
    topic_arn = data.aws_ssm_parameter.hmpps-offender-events-topic-arn.value
  }
}

data "aws_ssm_parameter" "hmpps-offender-events-topic-arn" {
  name = "/offender-events-${var.environment}/topic-arn"
}
