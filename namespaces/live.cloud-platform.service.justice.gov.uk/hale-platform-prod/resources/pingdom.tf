provider "pingdom" {
}

locals {
  websites = {
    brook-house-inquiry                = { host = "brookhouseinquiry.org.uk", url = "/" }
    cjji                               = { host = "cjji.justiceinspectorates.gov.uk", url = "/" }
    criminal-cases-review-commission   = { host = "ccrc.gov.uk", url = "/" }
    hmcpsi                             = { host = "hmcpsi.justiceinspectorates.gov.uk", url = "/" }
    icrir                              = { host = "icrir.independent-inquiry.uk", url = "/" }
    icrir-intranet                     = { host = "intranet.icrir.independent-inquiry.uk", url = "/" }
    imb-members                        = { host = "my.imb.org.uk", url = "/" }
    independent-monitoring-boards      = { host = "imb.org.uk", url = "/" }
    justice-inspectorates              = { host = "justiceinspectorates.gov.uk", url = "/" }
    justice-jobs                       = { host = "jobs.justice.gov.uk", url = "/" }
    law-commission                     = { host = "lawcom.gov.uk", url = "/" }
    lay-obs                            = { host = "members.layobservers.org", url = "/" }
    lay-observers                      = { host = "layobservers.org", url = "/" }
    magistrates-recruitment            = { host = "magistrates.judiciary.uk", url = "/" }
    national-preventive-mechanism      = { host = "nationalpreventivemechanism.org.uk", url = "/" }
    new-futures-network                = { host = "newfuturesnetwork.gov.uk", url = "/" }
    omagh-inquiry                      = { host = "omagh.independent-inquiry.uk", url = "/" }
    prison-and-probation-jobs          = { host = "prisonandprobationjobs.gov.uk", url = "/" }
    prisons-and-probation-ombudsman    = { host = "ppo.gov.uk", url = "/" }
    public-defender-service            = { host = "publicdefenderservice.org.uk", url = "/" }
    recriwtio-ynadon                   = { host = "magistrates.judiciary.uk", url = "/cymraeg" }
    showcase                           = { host = "showcase.websitebuilder.service.justice.gov.uk", url = "/" }
    sifocc                             = { host = "sifocc.org", url = "/" }
    victim-and-witness-information     = { host = "victimandwitnessinformation.org.uk", url = "/" }
    victim-and-witness-information-cym = { host = "cym.victimandwitnessinformation.org.uk", url = "/" }
    victims-commissioner               = { host = "victimscommissioner.org.uk", url = "/" }
    Website-Builder-Prod-Platform-Page = { host = "websitebuilder.service.justice.gov.uk", url = "/" }
    Website-Builder-Staging-Test-Site  = { host = "staging.websitebuilder.service.justice.gov.uk", url = "/" }
    Ministy-of-Justice-Main-Site       = { host = "www.justice.gov.uk", url = "/" }
  }
}

resource "pingdom_check" "hale-platform-websites" {
  for_each                 = local.websites
  type                     = "http"
  name                     = each.key
  host                     = each.value.host
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 4
  notifyagainevery         = 0
  url                      = each.value.url
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_${var.application},component_ping,isproduction_${var.is_production},infrastructuresupport_${var.application}"
  probefilters             = "region:EU"
  integrationids           = [133317]
}
