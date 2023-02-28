provider "pingdom" {
}

resource "pingdom_check" "laa-criminal-applications-datastore-healthcheck" {
  type                     = "http"
  name                     = "laa-criminal-applications-datastore-healthcheck - staging - cloud-platform"
  host                     = "criminal-applications-datastore-staging.apps.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_laa-criminal-applications-datastore,component_ping,isproduction_${var.is_production},environment_staging,infrastructuresupport_crime-apply-team"
  probefilters             = "region:EU"
  integrationids           = [123196]
}
