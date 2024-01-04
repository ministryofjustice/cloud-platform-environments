provider "pingdom" {
}

locals {
    websites = {
        "Website-Builder-Staging-Test-Site" = { host = "hale-platform-staging.apps.live.cloud-platform.service.justice.gov.uk", url = "/core" }
        "magistrates-recruitment" = { host = "magistrates.judiciary.uk", url = "/" }
        "criminal-cases-review-commission" = { host = "ccrc.gov.uk", url = "/" }
        "victims-commissioner" = { host = "victimscommissioner.org.uk", url = "/" }
        "lay-observers" = { host = "layobservers.org", url = "/" }
        "recriwtio-ynadon" = { host = "magistrates.judiciary.uk", url = "/cymraeg" }
        "public-defender-service" = { host = "publicdefenderservice.org.uk", url = "/" }
        "independent-monitoring-boards" = { host = "imb.org.uk", url = "/" }
        "victim-and-witness-information" = { host = "victimandwitnessinformation.org.uk", url = "/" }
        "independent-commission-for-reconciliation-and-information-recovery" = { host = "icrir.independent-inquiry.uk", url = "/" }
        "prison-and-probation-jobs" = { host = "prisonandprobationjobs.gov.uk", url = "/" }
        "brook-house-inquiry" = { host = "brookhouseinquiry.org.uk", url = "/" }
        "law-commission" = { host = "lawcom.gov.uk", url = "/" }
        "justice-jobs" = { host = "jobs.justice.gov.uk", url = "/" }
        "prisons-and-probation-ombudsman" = { host = "ppo.gov.uk", url = "/" }
        "standing-international-forum-of-commercial-courts" = { host = "sifocc.org", url = "/" }
        "imb-members" = { host = "my.imb.org.uk", url = "/" }
        "lay-obs" = { host = "hale-platform-prod.apps.live.cloud-platform.service.justice.gov.uk", url = "/layobsmembers" }
    }
}

resource "pingdom_check" "hale-platform-websites" {
    for_each                 = local.websites
    type                     = "http"
    name                     = each.key
    host                     = each.value.host
    resolution               = 1
    notifywhenbackup         = true
    sendnotificationwhendown = 6
    notifyagainevery         = 0
    url                      = each.value.url
    encryption               = true
    port                     = 443
    tags                     = "businessunit_${var.business_unit},application_${var.application},component_ping,isproduction_${var.is_production},infrastructuresupport_${var.application}"
    probefilters             = "region:EU"
    integrationids           = [133317]
}