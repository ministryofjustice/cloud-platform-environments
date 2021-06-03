provider "pingdom" {
}

# Integration IDs
# ????? =  #help-with-prison-visits-alerts

resource "pingdom_check" "help-with-prison-visits-external" {
  type                     = "http"
  name                     = "${var.application}-external"
  host                     = "help-with-prison-visits.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/status"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business-unit},application_${var.application}-external,isproduction_${var.is-production},owner_${var.infrastructure-support}"
  probefilters             = "region:EU"
  integrationids           = []
}

resource "pingdom_check" "help-with-prison-visits-internal" {
  type                     = "http"
  name                     = "${var.application}-internal"
  host                     = "manage.hwpv.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/status"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business-unit},application_${var.application}-internal,isproduction_${var.is-production},owner_${var.infrastructure-support}"
  probefilters             = "region:EU"
  integrationids           = []
}