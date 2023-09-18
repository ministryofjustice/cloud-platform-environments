provider "pingdom" {
}

resource "pingdom_check" "laa-apply-for-criminal-legal-aid-healthcheck" {
  type                     = "http"
  name                     = "LAA Apply for criminal legal aid - Staging"
  host                     = "staging.apply-for-criminal-legal-aid.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 4
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "laa-crime-apply,businessunit_${var.business_unit},application_laa-apply-for-criminal-legal-aid,component_ping,isproduction_${var.is_production},environment_staging,infrastructuresupport_crime-apply-team"
  probefilters             = "region:EU"
  integrationids           = [123196]
}

resource "pingdom_check" "laa-apply-for-criminal-legal-aid-datastore-healthcheck" {
  type                     = "http"
  name                     = "LAA Apply for criminal legal aid -> Datastore Staging"
  host                     = "staging.apply-for-criminal-legal-aid.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 4
  notifyagainevery         = 0
  url                      = "/datastore/ping"
  encryption               = true
  port                     = 443
  tags                     = "laa-crime-apply,laa-crime-apply-datastore-staging,businessunit_${var.business_unit},application_laa-apply-for-criminal-legal-aid,component_ping,isproduction_${var.is_production},environment_staging,infrastructuresupport_crime-apply-team"
  probefilters             = "region:EU"
  integrationids           = [123196]
}
