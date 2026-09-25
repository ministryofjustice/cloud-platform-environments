data "aws_ssm_parameter" "returns_events_topic_arn" {
  name = "/hmpps-ems-cemo-ui-dev/returns-events-topic-arn"
}


resource "kubernetes_secret" "returns_events_sns_topic" {
  metadata {
    name      = "returns-events-sns-topic"
    namespace = var.namespace
  }

  data = {
    topic_arn = data.aws_ssm_parameter.returns_events_topic_arn.value
  }
}