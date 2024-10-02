variable "domains" {
  type = map(string)
  default = {
    "dev.websitebuilder.service.justice.gov.uk" = "websitebuilder-demo"
  }
}

resource "kubernetes_manifest" "certificate" {
  for_each = var.domains

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = each.key
      namespace = "hale-platform-demo"
    }
    spec = {
      dnsNames = [each.key]
      issuerRef = {
        kind = "ClusterIssuer"
        name = "letsencrypt-production"
      }
      secretName = "${each.value}-cert"
    }
  }
}
