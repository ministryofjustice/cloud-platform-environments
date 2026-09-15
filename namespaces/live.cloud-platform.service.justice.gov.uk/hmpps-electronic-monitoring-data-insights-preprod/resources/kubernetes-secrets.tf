resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "${var.namespace}-irsa-output"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.role_name
    serviceaccount = module.irsa.service_account.name
  }
}

resource "kubernetes_secret" "athena_roles" {
  metadata {
    name      = "athena-roles"
    namespace = var.namespace
  }
  type = "Opaque"
  data = {
    general_role_arn = "arn:aws:iam::443370694497:role/emdi_read_emds_data_preprod"
  }
}

