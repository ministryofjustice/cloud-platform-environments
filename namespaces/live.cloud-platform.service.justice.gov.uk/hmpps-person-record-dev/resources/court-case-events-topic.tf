resource "kubernetes_secret" "court-case-events" {
  metadata {
    name      = "court-case-events-topic"
    namespace = var.namespace
  }

  data = {
    topic_arn = data.aws_ssm_parameter.court-case-events-topic-arn.value
  }
}
