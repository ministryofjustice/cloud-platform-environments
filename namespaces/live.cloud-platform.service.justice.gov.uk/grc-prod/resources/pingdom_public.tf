
provider "pingdom" {
}

resource "pingdom_check" "grc-public-production" {
  type                     = "http"
  name                     = "Gender Recognitiono ServicePublic production - Healthcheck"
  host                     = "genderrecognition.service.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_true,environment_uat,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  integrationids           = [94618]
}

