provider "pingdom" {
}

resource "pingdom_check" "laa-apply-for-criminal-legal-aid-healthcheck" {
  type                     = "http"
  name                     = "laa-apply-for-criminal-legal-aid-healthcheck - staging - cloud-platform"
  host                     = "laa-apply-for-criminal-legal-aid-staging.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_laa-apply-for-criminal-legal-aid,component_ping,isproduction_${var.is_production},environment_staging,infrastructuresupport_crime-apply-team"
  probefilters             = "region:EU"
  integrationids           = [123196]
}
