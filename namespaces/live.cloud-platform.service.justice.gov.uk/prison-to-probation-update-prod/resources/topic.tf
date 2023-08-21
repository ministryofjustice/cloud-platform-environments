data "aws_sns_topic" "prison-offender-events" {
  name = "cloud-platform-Digital-Prison-Services-160f3055cc4e04c4105ee85f2ed1fccb"
}

data "aws_sns_topic" "hmpps-domain-events" {
  name = "cloud-platform-Digital-Prison-Services-97e6567cf80881a8a52290ff2c269b08"
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
