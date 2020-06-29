data "kubernetes_secret" "pict-cpmg-wildfly-credentials" {
  metadata {
    name      = "pict-cpmg-wildfly-credentials"
    namespace = "crime-portal-mirror-gateway-dev"
  }
}

resource "kubernetes_secret" "pict-cpmg-wildfly-credentials" {
  metadata {
    name      = "pict-cpmg-wildfly-credentials"
    namespace = "court-probation-dev"
  }

  data = {
    adminuser      = data.kubernetes_secret.pict-cpmg-wildfly-credentials.data["adminuser"]
    jmsuser        = data.kubernetes_secret.pict-cpmg-wildfly-credentials.data["jmsuser"]
    owner-password = data.kubernetes_secret.pict-cpmg-wildfly-credentials.data["owner-password"]
    user-password  = data.kubernetes_secret.pict-cpmg-wildfly-credentials.data["user-password"]
  }
}
