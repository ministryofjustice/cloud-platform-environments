provider "pingdom" {
}

resource "pingdom_check" "laa-review-criminal-legal-aid-healthcheck" {
  type                     = "http"
  name                     = "LAA Review criminal legal aid applications - Production"
  host                     = "review-criminal-legal-aid.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 2
  notifyagainevery         = 60
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "laa-crime-apply,businessunit_${var.business_unit},application_laa-review-criminal-legal-aid,component_ping,isproduction_${var.is_production},environment_production,infrastructuresupport_crime-apply-team"
  probefilters             = "region:EU"
  integrationids           = [123196]
}

resource "pingdom_check" "laa-review-criminal-legal-aid-datastore-healthcheck" {
  type                     = "http"
  name                     = "LAA Review criminal legal aid applications -> Datastore Production"
  host                     = "review-criminal-legal-aid.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 2
  notifyagainevery         = 60
  url                      = "/datastore/ping"
  encryption               = true
  port                     = 443
  tags                     = "laa-crime-apply,laa-crime-review-datastore-production,businessunit_${var.business_unit},application_laa-review-criminal-legal-aid,component_ping,isproduction_${var.is_production},environment_production,infrastructuresupport_crime-apply-team"
  probefilters             = "region:EU"
  integrationids           = [123196]
}
