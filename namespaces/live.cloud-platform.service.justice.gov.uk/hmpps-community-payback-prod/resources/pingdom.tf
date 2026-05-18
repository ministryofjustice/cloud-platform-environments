provider "pingdom" {
}

resource "pingdom_check" "hmpps-community-payback-ui" {
  type                     = "http"
  name                     = "HMPPS - community-payback-ui - Production"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/community-payback.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_hmpps-community-payback-ui,component_healthcheck,isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_${var.slack_channel}"
  probefilters             = "region:EU"
  integrationids           = [147808]
}

resource "pingdom_check" "hmpps-community-payback-supervisors-ui" {
  type                     = "http"
  name                     = "HMPPS - community-payback-supervisors-ui - Production"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/community-payback-supervisors.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_community-payback-supervisors-ui,component_healthcheck,isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_${var.slack_channel}"
  probefilters             = "region:EU"
  integrationids           = [147808]
}

resource "pingdom_check" "hmpps-community-payback-api" {
  type                     = "http"
  name                     = "HMPPS - community-payback-api - Production"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/community-payback-api.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_hmpps-community-payback-api,component_healthcheck,isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_${var.slack_channel}"
  probefilters             = "region:EU"
  integrationids           = [147808]
}
