provider "pingdom" {
}

resource "pingdom_check" "justicedata-pingdom" {
  type                     = "http"
  name                     = "justicedata - production - cloud-platform"
  host                     = "data.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_hmpps,application_justicedata,component_ping,isproduction_true,environment_production,performance_hub_dev"
  probefilters             = "region:EU"
  integrationids           = [114774]
}