data "aws_sns_topic" "prison-offender-events" {
  name = "cloud-platform-Digital-Prison-Services-d448bb61bb0b69b82fb19a3fa574e7f9"
}

data "aws_sns_topic" "hmpps-domain-events" {
  name = "cloud-platform-Digital-Prison-Services-15b2b4a6af7714848baeaf5f41c85fcd"
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
