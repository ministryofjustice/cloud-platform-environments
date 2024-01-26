provider "pingdom" {
}

resource "pingdom_check" "hmpps-approved-premises-ui" {
  type                     = "http"
  name                     = "HMPPS - approved-premises/CAS1 - Production"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  integrationids           = [130656, 130657]
  notifyagainevery         = 0
  url                      = "/https/approved-premises.hmpps.service.justice.gov.uk/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_hmpps,application_approved-premises,component_healthcheck,isproduction_true,environment_production,infrastructuresupport_cas-dev"
  probefilters             = "region:EU"
}

resource "pingdom_check" "hmpps-community-accommodation-tier-2-ui" {
  type                     = "http"
  name                     = "HMPPS - short-term-accommodation-cas-2/CAS2 - Production"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  integrationids           = [133623]
  notifyagainevery         = 0
  url                      = "/https/short-term-accommodation-cas-2.hmpps.service.justice.gov.uk/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_hmpps,application_short-term-accommodation-cas-2,component_healthcheck,isproduction_true,environment_production,infrastructuresupport_cas-dev"
  probefilters             = "region:EU"
}

resource "pingdom_check" "hmpps-temporary-accommodation-ui" {
  type                     = "http"
  name                     = "HMPPS - transitional-accommodation/CAS3 - Production"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  integrationids           = [130657]
  notifyagainevery         = 0
  url                      = "/https/transitional-accommodation.hmpps.service.justice.gov.uk/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_hmpps,application_temporary-accommodation,component_healthcheck,isproduction_true,environment_production,infrastructuresupport_cas-dev"
  probefilters             = "region:EU"
}

resource "pingdom_check" "hmpps-approved-premises-api" {
  type                     = "http"
  name                     = "HMPPS - approved-premises-api - Production"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  integrationids           = [130656, 130657]
  notifyagainevery         = 0
  url                      = "/https/approved-premises-api.hmpps.service.justice.gov.uk/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_hmpps,application_approved-premises-api,component_healthcheck,isproduction_true,environment_production,infrastructuresupport_cas-dev"
  probefilters             = "region:EU"
}
