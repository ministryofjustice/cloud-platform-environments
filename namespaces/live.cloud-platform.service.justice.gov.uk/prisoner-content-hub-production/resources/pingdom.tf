provider "pingdom" {
}

# Integration IDs
# 122531 = #launchpad-alerts

resource "pingdom_check" "prisoner-content-hub-frontend-production" {
  type                     = "http"
  name                     = "Prisoner Content Hub Frontend"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/content-hub.prisoner.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed,businessunit_${var.business_unit},application_prisoner_content_hub,component_healthcheck,isproduction_${var.is_production},environment_${var.environment-name},infrastructuresupport_platforms"
  probefilters             = "region:EU"
  integrationids           = [122531]
}

resource "pingdom_check" "prisoner-content-hub-backend-production" {
  type                     = "http"
  name                     = "Prisoner Content Hub Backend"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/manage.content-hub.prisoner.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed,businessunit_${var.business_unit},application_prisoner_content_hub,component_healthcheck,isproduction_${var.is_production},environment_${var.environment-name},infrastructuresupport_platforms"
  probefilters             = "region:EU"
  integrationids           = [122531]
}
