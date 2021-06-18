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
  tags                     = "businessunit_hmpps,application_justicedata,component_ping,isproduction_false,environment_staging,hubusers@justice.gov.uk"
  probefilters             = "region:EU"
  integrationids           = [114774]
}