data "kubernetes_secret" "pict-cpmg-wildfly-credentials" {
  metadata {
    name      = "pict-cpmg-wildfly-credentials"
    namespace = "crime-portal-mirror-gateway"
  }
}
