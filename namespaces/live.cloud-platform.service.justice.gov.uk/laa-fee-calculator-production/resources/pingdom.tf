provider "pingdom" {
}

resource "pingdom_check" "laa-fee-calculator-production" {
  type                     = "http"
  name                     = "LAA fee calculator production - ping"
  host                     = var.domain
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping.json"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_laa-fee-calculator,component_ping,isproduction_${var.is_production},environment_${var.environment-name},infrastructuresupport_laa-fee-calculator,laa_production_environment_dashboard"
  probefilters             = "region:EU"
  integrationids           = [116478]
}
