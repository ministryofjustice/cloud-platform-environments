resource "random_password" "adminuser_password" {
  length  = 16
  special = true
}

resource "random_password" "jmsuser_password" {
  length  = 16
  special = true
}

resource "kubernetes_secret" "pict_cpmg_wildfly_credentials" {
  metadata {
    name      = "pict_cpmg_wildfly_credentials"
    namespace = "crime-portal-mirror-gateway-dev"
  }

  data = {
    admin          = "appuser"
    owner-password = random_password.adminuser_password.result
    jmsuser        = "jmsuser"
    user-password  = random_password.jmsuser_password.result
  }
}
