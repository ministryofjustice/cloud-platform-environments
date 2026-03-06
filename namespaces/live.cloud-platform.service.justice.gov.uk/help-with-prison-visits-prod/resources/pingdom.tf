provider "pingdom" {
}

# Integration IDs
# 116039 =  #help-with-prison-visits-alerts

resource "pingdom_check" "help-with-prison-visits-external" {
  type                     = "http"
  name                     = "${var.application}-external"
  host                     = "help-with-prison-visits.service.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_${var.application}-external,isproduction_${var.is_production},owner_prison-visits-booking"
  probefilters             = "region:EU"
  integrationids           = [116039]
}

resource "pingdom_check" "help-with-prison-visits-internal" {
  type                     = "http"
  name                     = "${var.application}-internal"
  host                     = "caseworker.help-with-prison-visits.service.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_${var.application}-internal,isproduction_${var.is_production},owner_prison-visits-booking"
  probefilters             = "region:EU"
  integrationids           = [116039]
}
