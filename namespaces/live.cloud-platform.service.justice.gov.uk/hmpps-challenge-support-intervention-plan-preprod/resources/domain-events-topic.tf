resource "kubernetes_secret" "hmpps_csip_hmpps_domain_events_topic" {
  metadata {
    name      = "hmpps-domain-events-topic"
    namespace = var.namespace
  }

  data = {
    topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  }
}

data "aws_ssm_parameter" "hmpps-domain-events-topic-arn" {
  name = "/hmpps-domain-events-preprod/topic-arn"
}
