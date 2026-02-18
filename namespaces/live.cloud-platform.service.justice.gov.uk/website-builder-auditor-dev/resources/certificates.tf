variable "domains" {
  type = map(string)
  default = {
    "auditor.websitebuilder.service.justice.gov.uk" = "websitebuilder-auditor"
  }
}

resource "kubernetes_manifest" "certificate" {
  for_each = var.domains

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = each.key
      namespace = "website-builder-auditor-dev"
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
