provider "pingdom" {
}

resource "pingdom_check" "laa-manage-your-civil-cases-uat" {
  type                     = "http"
  name                     = "Manage your civil cases - uat - ping"
  host                     = "main-manage-your-civil-cases-uat.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_${var.application},component_ping,isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_${var.infrastructure_support}"
  probefilters             = "region:EU"
  integrationids           = [143418]
}
