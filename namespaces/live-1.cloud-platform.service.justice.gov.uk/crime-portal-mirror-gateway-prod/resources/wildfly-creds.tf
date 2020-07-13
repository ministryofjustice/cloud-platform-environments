resource "random_password" "jmsuser_password" {
  length  = 16
  special = true
}

resource "kubernetes_secret" "pict_cpmg_wildfly_credentials" {
  metadata {
    name      = "pict-cpmg-wildfly-credentials"
    namespace = var.namespace
  }

  data = {
    jmsuser       = "jmsuser"
    user-password = random_password.jmsuser_password.result
  }
}
