provider "pingdom" {
}

resource "pingdom_check" "laa-apply-for-criminal-legal-aid-healthcheck" {
  type                     = "http"
  name                     = "LAA Apply for criminal legal aid - Production"
  host                     = "apply-for-criminal-legal-aid.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 2
  notifyagainevery         = 60
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_laa-apply-for-criminal-legal-aid,component_ping,isproduction_${var.is_production},environment_production,infrastructuresupport_crime-apply-team"
  probefilters             = "region:EU"
  integrationids           = [123196]
}
