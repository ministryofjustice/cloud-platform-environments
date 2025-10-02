data "aws_ssm_parameter" "sqs_queue_arn" {
  name = "/${var.producer_namespace}/sqs-queue-arn"
}

data "aws_ssm_parameter" "sqs_policy_arn" {
  name = "/${var.producer_namespace}/sqs-policy-arn"
}

resource "kubernetes_secret" "sqs_queue_arn" {
  metadata {
    name      = "${var.namespace}-sqs-arn"
    namespace = var.namespace
  }
  data = {
    arn = data.aws_ssm_parameter.sqs_queue_arn.value
  }
}