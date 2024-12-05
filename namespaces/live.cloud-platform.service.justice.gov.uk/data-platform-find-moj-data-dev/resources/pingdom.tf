provider "pingdom" {
}

resource "pingdom_check" "find-moj-data-dev" {
  type                     = "http"
  name                     = "find-moj-data - dev - cloud-platform"
  host                     = "dev.find-moj-data.service.justice.gov.uk"
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