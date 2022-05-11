provider "pingdom" {
}

resource "pingdom_check" "laa-crime-means-assessment-test" {
  type                     = "http"
  name                     = "LAA Crime Means Assessment - Prod"
  host                     = "laa-crime-means-assessment-prod.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/actuator/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_laa,application_laa-crime-means-assessment,component_ping,isproduction_true,environment_test,owner_laa-crime-apps-team"
  probefilters             = "region:EU"
  integrationids           = [121160]
}