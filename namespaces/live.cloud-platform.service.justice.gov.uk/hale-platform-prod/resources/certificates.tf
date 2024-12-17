variable "domains" {
  type = map(string)
  default = {
    "advance-into-justice.service.justice.gov.uk"     = "advance-into-justice"
    "andrewmalkinson.independent-inquiry.uk"          = "andrewmalkinson"
    "archive.ppo.gov.uk"                              = "ppo-archive"
    "bold.websitebuilder.service.justice.gov.uk"      = "websitebuilder-bold"
    "brookhouseinquiry.org.uk"                        = "brookhouse"
    "ccrc.gov.uk"                                     = "ccrc"
    "cjji.justiceinspectorates.gov.uk"                = "justiceinspectorates-cjji"
    "cym.victimandwitnessinformation.org.uk"          = "victimandwitnessinformation-cym"
    "cym.victimscode.org.uk"                          = "victimscode-cym"
    "hmcpsi.justiceinspectorates.gov.uk"              = "justiceinspectorates-hmcpsi"
    "hmiprisons.justiceinspectorates.gov.uk"          = "justiceinspectorates-hmiprisons"
    "iapondeathsincustody.org"                        = "iapdc"
    "iapdeathsincustody.independent.gov.uk"           = "iapdci"
    "icrir.independent-inquiry.uk"                    = "icrir"
    "imb.org.uk"                                      = "imb"
    "intranet.hmiprisons.justiceinspectorates.gov.uk" = "justiceinspectorates-hmiprisons-intranet"
    "intranet.icrir.independent-inquiry.uk"           = "icrir-intranet"
    "justiceinspectorates.gov.uk"                     = "justiceinspectorates"
    "lawcom.gov.uk"                                   = "lawcom"
    "layobservers.org"                                = "layobservers"
    "legalaidlearning.justice.gov.uk"                 = "legalaidlearning"
    "magistrates.judiciary.uk"                        = "magistrates"
    "members.layobservers.org"                        = "layobservers-members"
    "my.imb.org.uk"                                   = "my-imb"
    "nationalpreventivemechanism.org.uk"              = "nationalpreventivemechanism"
    "newfuturesnetwork.gov.uk"                        = "newfuturesnetwork"
    "omagh.independent-inquiry.uk"                    = "obi"
    "ppo.gov.uk"                                      = "ppo"
    "prisonandprobationjobs.gov.uk"                   = "ppj"
    "prod.websitebuilder.service.justice.gov.uk"      = "websitebuilder-prod"
    "publicdefenderservice.org.uk"                    = "publicdefenderservice"
    "seewhatsontheinside.co.uk"                       = "swoti-uk"
    "seewhatsontheinside.com"                         = "swoti"
    "showcase.websitebuilder.service.justice.gov.uk"  = "websitebuilder-showcase"
    "sifocc.org"                                      = "sifocc"
    "victimandwitnessinformation.org.uk"              = "victimandwitnessinformation"
    "victimscode.org.uk"                              = "victimscode"
    "victimscommissioner.org.uk"                      = "victimscommissioner"
    "websitebuilder.service.justice.gov.uk"           = "websitebuilder"
    "www.advance-into-justice.service.justice.gov.uk" = "advance-into-justice-www"
    "www.andrewmalkinson.independent-inquiry.uk"      = "andrewmalkinson-www"
    "www.brookhouseinquiry.org.uk"                    = "brookhouse-www"
    "www.ccrc.gov.uk"                                 = "ccrc-www"
    "www.cjji.justiceinspectorates.gov.uk"            = "justiceinspectorates-cjji-www"
    "www.hmcpsi.justiceinspectorates.gov.uk"          = "justiceinspectorates-hmcpsi-www"
    "www.iapondeathsincustody.org"                    = "iapdc-www"
    "www.iapdeathsincustody.independent.gov.uk"       = "iapdci-www"
    "www.imb.org.uk"                                  = "imb-www"
    "www.justiceinspectorates.gov.uk"                 = "justiceinspectorates-www"
    "www.lawcom.gov.uk"                               = "lawcom-www"
    "www.layobservers.org"                            = "layobservers-www"
    "www.legalaidlearning.justice.gov.uk"             = "legalaidlearning-www"
    "www.magistrates.judiciary.uk"                    = "magistrates-www"
    "www.nationalpreventivemechanism.org.uk"          = "nationalpreventivemechanism-www"
    "www.newfuturesnetwork.gov.uk"                    = "newfuturesnetwork-www"
    "www.omagh.independent-inquiry.uk"                = "obi-www"
    "www.ppo.gov.uk"                                  = "ppo-www"
    "www.prisonandprobationjobs.gov.uk"               = "ppj-www"
    "www.publicdefenderservice.org.uk"                = "publicdefenderservice-www"
    "www.seewhatsontheinside.co.uk"                   = "swoti-uk-www"
    "www.seewhatsontheinside.com"                     = "swoti-www"
    "www.sifocc.org"                                  = "sifocc-www"
    "www.victimandwitnessinformation.org.uk"          = "victimandwitnessinformation-www"
    "www.victimscode.org.uk"                          = "victimscode-www"
    "www.victimscommissioner.org.uk"                  = "victimscommissioner-www"
    "www.websitebuilder.service.justice.gov.uk"       = "websitebuilder-www"
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
