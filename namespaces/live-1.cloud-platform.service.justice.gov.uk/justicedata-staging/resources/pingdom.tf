provider "pingdom" {
}

resource "pingdom_check" "justicedata-pingdom" {
  type                     = "http"
  name                     = "justicedata - staging - cloud-platform"
  host                     = "staging.data.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_$(var.business_unit),application_justicedata,component_ping,isproduction_$(var.is_production),environment_staging,$(var.infrastructure_support)"
  probefilters             = "region:EU"
  integrationids           = []
}