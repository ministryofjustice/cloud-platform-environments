data "kubernetes_secret" "pict-cpmg-wildfly-credentials" {
  metadata {
    name      = "pict-cpmg-wildfly-credentials"
    namespace = "crime-portal-mirror-gateway-preprod"
  }
}

resource "kubernetes_secret" "pict-cpmg-wildfly-credentials" {
  metadata {
    name      = "pict-cpmg-wildfly-credentials"
    namespace = "court-probation-preprod"
  }

  data = {
    jmsuser       = data.kubernetes_secret.pict-cpmg-wildfly-credentials.data["jmsuser"]
    user-password = data.kubernetes_secret.pict-cpmg-wildfly-credentials.data["user-password"]
  }
}
