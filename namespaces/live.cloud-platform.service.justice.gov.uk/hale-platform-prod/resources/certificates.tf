variable "domains" {
  type = map(string)
  default = {
    "magistrates.judiciary.uk"               = "magistrates"
    "victimscommissioner.org.uk"             = "victimscommissioner"
    "www.victimscommissioner.org.uk"         = "victimscommissioner-www"
    "publicdefenderservice.org.uk"           = "publicdefenderservice"
    "www.publicdefenderservice.org.uk"       = "publicdefenderservice-www"
    "imb.org.uk"                             = "imb"
    "www.imb.org.uk"                         = "imb-www"
    "my.imb.org.uk"                          = "my-imb"
    "ccrc.gov.uk"                            = "ccrc"
    "www.ccrc.gov.uk"                        = "ccrc-www"
    "icrir.independent-inquiry.uk"           = "icrir"
    "prisonandprobationjobs.gov.uk"          = "ppj"
    "www.prisonandprobationjobs.gov.uk"      = "ppj-www"
    "brookhouseinquiry.org.uk"               = "brookhouse"
    "www.brookhouseinquiry.org.uk"           = "brookhouse-www"
    "layobservers.org"                       = "layobservers"
    "www.layobservers.org"                   = "layobservers-www"
    "members.layobservers.org"               = "layobservers-members"
    "sifocc.org"                             = "sifocc"
    "www.sifocc.org"                         = "sifocc-www"
    "nationalpreventivemechanism.org.uk"     = "nationalpreventivemechanism"
    "www.nationalpreventivemechanism.org.uk" = "nationalpreventivemechanism-www"
    "jobs.justice.gov.uk"                    = "justicejobs"
    "www.jobs.justice.gov.uk"                = "justicejobs-www"
    "ppo.gov.uk"                             = "ppo"
    "www.ppo.gov.uk"                         = "ppo-www"
    "lawcom.gov.uk"                          = "lawcom"
    "www.lawcom.gov.uk"                      = "lawcom-www"
    "victimandwitnessinformation.org.uk"     = "victimandwitnessinformation"
    "www.victimandwitnessinformation.org.uk" = "victimandwitnessinformation-www"
    "cym.victimandwitnessinformation.org.uk" = "victimandwitnessinformation-cym"
    "victimscode.org.uk"                     = "victimscode"
    "omagh.independent-inquiry.uk"           = "obi"
    "www.omagh.independent-inquiry.uk"       = "obi-www"
  }
}

resource "kubernetes_manifest" "certificate" {
  for_each = var.domains

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = each.key
      namespace = "hale-platform-prod"
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
