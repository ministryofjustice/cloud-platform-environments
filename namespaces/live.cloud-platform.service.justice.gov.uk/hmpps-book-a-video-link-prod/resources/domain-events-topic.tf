resource "kubernetes_secret" "hmpps_book_a_video_link_topic" {
  metadata {
    name      = "hmpps-domain-events-topic"
    namespace = var.namespace
  }

  data = {
    topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  }
}

data "aws_ssm_parameter" "hmpps-domain-events-topic-arn" {
  name = "/hmpps-domain-events-${var.environment}/topic-arn"
}

