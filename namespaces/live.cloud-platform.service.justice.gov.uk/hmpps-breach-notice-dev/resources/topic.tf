data "aws_ssm_parameter" "hmpps-domain-events-topic-arn" {
  name = "/hmpps-domain-events-${var.environment_name}/topic-arn"
}

resource "kubernetes_secret" "topic-secret" {
  metadata {
    namespace = var.namespace
    name      = "hmpps-domain-events"
  }
  data = {
    topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  }
}
