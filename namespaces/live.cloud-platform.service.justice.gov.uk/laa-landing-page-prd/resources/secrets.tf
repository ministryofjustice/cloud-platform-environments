resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "${var.namespace}-irsa"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.role_name
    serviceaccount = module.irsa.service_account.name
    rolearn        = module.irsa.role_arn
  }
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