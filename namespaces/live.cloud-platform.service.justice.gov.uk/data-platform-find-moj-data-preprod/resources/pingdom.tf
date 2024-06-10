provider "pingdom" {
}

resource "pingdom_check" "find-moj-data-preprod" {
  type                     = "http"
  name                     = "find-moj-data - preprod - cloud-platform"
  host                     = "data-platform-find-moj-data-preprod.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_find_moj_data,component_ping,isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_${var.business_unit}"
  probefilters             = "region:EU"
  integrationids           = [135556]
}