provider "pingdom" {
}

resource "pingdom_check" "laa-crime-means-assessment-uat" {
  type                     = "http"
  name                     = "LAA Crime Means Assessment - Uat"
  host                     = "laa-crime-means-assessment-uat.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/actuator/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_laa,application_laa-crime-means-assessment,component_ping,isproduction_false,environment_uat,owner_laa-crime-apps-team"
  probefilters             = "region:EU"
  integrationids           = [121160]
}