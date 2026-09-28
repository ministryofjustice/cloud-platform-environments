resource "random_password" "dpr_password" {
  length  = 16
  special = false
}

resource "kubernetes_secret" "digital_prison_reporting" {
  metadata {
    name      = "digital-prison-reporting"
    namespace = var.namespace
  }

  data = {
    DPR_USER     = "digital_prison_reporting"
    DPR_PASSWORD = random_password.dpr_password.result
  }
}
