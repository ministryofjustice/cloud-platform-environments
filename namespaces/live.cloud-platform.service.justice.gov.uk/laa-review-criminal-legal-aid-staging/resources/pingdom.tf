provider "pingdom" {
}

resource "pingdom_check" "laa-review-criminal-legal-aid-staging-healthcheck" {
  type                     = "http"
  name                     = "laa-review-criminal-legal-aid-staging-healthcheck - staging - cloud-platform"
  host                     = "laa-review-criminal-legal-aid-staging.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_laa-review-criminal-legal-aid,component_ping,isproduction_${var.is_production},environment_staging,infrastructuresupport_crime-apply-team"
  probefilters             = "region:EU"
  integrationids           = [123196]
}
