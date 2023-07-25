provider "pingdom" {
}

resource "pingdom_check" "hmpps-approved-premises-ui" {
  type                     = "http"
  name                     = "HMPPS - approved-premises/CAS1 - Production"
  host                     = "approved-premises.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  integrationids           = [130656, 130657]
  notifyagainevery         = 0
  url                      = "/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_hmpps,application_approved-premises,component_healthcheck,isproduction_true,environment_production,infrastructuresupport_cas-dev"
  probefilters             = "region:EU"
}

resource "pingdom_check" "hmpps-temporary-accommodation-ui" {
  type                     = "http"
  name                     = "HMPPS - temporary-accommodation/CAS3 - Production"
  host                     = "temporary-accommodation.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  integrationids           = [130657]
  notifyagainevery         = 0
  url                      = "/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_hmpps,application_temporary-accommodation,component_healthcheck,isproduction_true,environment_production,infrastructuresupport_cas-dev"
  probefilters             = "region:EU"
}

resource "pingdom_check" "hmpps-approved-premises-api" {
  type                     = "http"
  name                     = "HMPPS - approved-premises-api - Production"
  host                     = "approved-premises-api.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  integrationids           = [130656, 130657]
  notifyagainevery         = 0
  url                      = "/health_check"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_hmpps,application_approved-premises-api,component_healthcheck,isproduction_true,environment_production,infrastructuresupport_cas-dev"
  probefilters             = "region:EU"
}
