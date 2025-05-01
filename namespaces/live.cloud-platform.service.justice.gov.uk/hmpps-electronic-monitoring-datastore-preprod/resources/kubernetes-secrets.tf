resource "kubernetes_secret" "athena_roles" {
  metadata {
    name      = "${var.namespace}-athena-roles"
    namespace = var.namespace
  }
  type = "Opaque"
  data = {
    general_role_arn = data.aws_ssm_parameter.athena_general_role_arn.value
    specials_role_arn = data.aws_ssm_parameter.athena_specials_role_arn.value
  }
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "${var.namespace}-irsa-output"
    namespace = var.namespace
  }
  data = {
    role = module.irsa.role_name
    serviceaccount = module.irsa.service_account.name
  }
}
