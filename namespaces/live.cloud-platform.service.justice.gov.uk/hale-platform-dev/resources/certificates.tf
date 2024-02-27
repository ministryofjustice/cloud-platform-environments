variable "domains" {
  type = map(string)
  default = {
    "test1.magistrates.judiciary.uk" = "magistrates-test1"
    "test1.layobservers.org"         = "layobservers-test1"
  }
}

resource "kubernetes_manifest" "certificate" {
  for_each = var.domains

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = each.key
      namespace = "hale-platform-dev"
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
