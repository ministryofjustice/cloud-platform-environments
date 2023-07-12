data "aws_sns_topic" "prison-offender-events" {
  name = "cloud-platform-Digital-Prison-Services-f221e27fcfcf78f6ab4f4c3cc165eee7"
}

data "aws_ssm_parameter" "hmpps-domain-events-topic-arn" {
  name = "/hmpps-domain-events-${var.environment}/topic-arn"
}

data "aws_sns_topic" "hmpps-domain-events" {
  name = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
}

data "aws_ssm_parameter" "hmpps-domain-events-policy-arn" {
  name = "/hmpps-domain-events-${var.environment}/sns/${data.aws_sns_topic.hmpps-domain-events.name}/irsa-policy-arn"
}

resource "kubernetes_secret" "hmpps-domain-events-secret" {
  metadata {
    name      = "hmpps-domain-events-topic"
    namespace = var.namespace
  }
  data = { TOPIC_ARN = data.aws_sns_topic.hmpps-domain-events.arn }
}
